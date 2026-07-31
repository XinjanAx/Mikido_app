import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_local_datasource.dart';
import '../models/tournament_model.dart';

/// Repositorio local-first: toda lectura viene de la base local (drift) y
/// toda escritura se guarda local de inmediato + se encola en el outbox
/// para subir a Supabase cuando haya conexión. La UI nunca espera a la red.
class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentLocalDataSource _local;
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  const TournamentRepositoryImpl(this._local, this._db, this._syncEngine);

  @override
  Future<Either<Failure, List<TournamentEntity>>> getTournaments() async {
    try {
      return Right(await _local.getTournaments());
    } catch (e) {
      return Left(CacheFailure(message: 'Error al leer torneos locales: $e'));
    }
  }

  @override
  Future<Either<Failure, TournamentEntity>> getTournamentById(
      String id) async {
    try {
      final result = await _local.getTournamentById(id);
      if (result == null) {
        return const Left(NotFoundFailure(message: 'Torneo no encontrado'));
      }
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al leer torneo local: $e'));
    }
  }

  @override
  Future<Either<Failure, TournamentEntity>> createTournament(
      TournamentEntity tournament) {
    return _saveLocally(TournamentModel.fromEntity(tournament));
  }

  @override
  Future<Either<Failure, TournamentEntity>> updateTournament(
      TournamentEntity tournament) {
    return _saveLocally(TournamentModel.fromEntity(tournament));
  }

  Future<Either<Failure, TournamentEntity>> _saveLocally(
      TournamentModel model) async {
    try {
      await _local.upsert(model, dirty: true);
      await _enqueue(rowId: model.id, operation: 'upsert', payload: model.toJson());
      unawaited(_syncEngine.trySync());
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al guardar torneo local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTournament(String id) async {
    try {
      // Borrado en cascada: sin esto, los encuentros e inscripciones del
      // torneo quedaban huérfanos apuntando a un torneo que ya no existe
      // — el caso real que vimos fue un participante que ya no se podía
      // eliminar porque seguía "inscrito" en un torneo fantasma.
      final matches = await _db.getMatchesByTournament(id);
      for (final m in matches) {
        await _db.softDeleteMatch(m.id);
        await _db.enqueueDelete(SupabaseConstants.matchesTable, m.id);
      }

      final enrollments = await _db.getPlayersWithEnrollmentByTournament(id);
      for (final (_, enrollment) in enrollments) {
        await _db.softDeleteEnrollment(enrollment.id);
        await _db.enqueueDelete(
            SupabaseConstants.enrollmentsTable, enrollment.id);
      }

      await _local.softDelete(id);
      await _enqueue(rowId: id, operation: 'delete', payload: null);
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al eliminar torneo local: $e'));
    }
  }

  @override
  Stream<List<TournamentEntity>> watchTournaments() =>
      _local.watchTournaments();

  Future<void> _enqueue({
    required String rowId,
    required String operation,
    required Map<String, dynamic>? payload,
  }) {
    return _db.enqueueSyncOp(SyncQueueEntriesCompanion.insert(
      id: const Uuid().v4(),
      entityTable: SupabaseConstants.tournamentsTable,
      rowId: rowId,
      operation: operation,
      payload: Value(payload == null ? null : jsonEncode(payload)),
    ));
  }
}
