import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_local_datasource.dart';
import '../models/player_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerLocalDataSource _local;
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  const PlayerRepositoryImpl(this._local, this._db, this._syncEngine);

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayers() async {
    try {
      return Right(await _local.getPlayers());
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al leer participantes locales: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> getPlayerById(String id) async {
    try {
      final result = await _local.getPlayerById(id);
      if (result == null) {
        return const Left(
            NotFoundFailure(message: 'Participante no encontrado'));
      }
      return Right(result);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al leer participante local: $e'));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> createPlayer(PlayerEntity player) async {
    try {
      if (await _findDuplicateName(player.name)) {
        return const Left(ValidationFailure(
            message: 'Ya existe un participante con ese nombre'));
      }
    } catch (e) {
      return Left(CacheFailure(message: 'Error al validar el nombre: $e'));
    }
    return _savePlayerLocally(PlayerModel.fromEntity(player));
  }

  @override
  Future<Either<Failure, PlayerEntity>> updatePlayer(PlayerEntity player) async {
    try {
      if (await _findDuplicateName(player.name, excludingId: player.id)) {
        return const Left(ValidationFailure(
            message: 'Ya existe un participante con ese nombre'));
      }
    } catch (e) {
      return Left(CacheFailure(message: 'Error al validar el nombre: $e'));
    }
    return _savePlayerLocally(PlayerModel.fromEntity(player));
  }

  /// Compara sin distinguir mayúsculas/minúsculas ni espacios extra, para
  /// que el nombre de cada participante sea único.
  Future<bool> _findDuplicateName(String name, {String? excludingId}) async {
    final normalized = name.trim().toLowerCase();
    final all = await _local.getPlayers();
    return all.any((p) =>
        p.id != excludingId && p.name.trim().toLowerCase() == normalized);
  }

  Future<Either<Failure, PlayerEntity>> _savePlayerLocally(
      PlayerModel model) async {
    try {
      await _local.upsertPlayer(model, dirty: true);
      await _enqueue(
        table: SupabaseConstants.playersTable,
        rowId: model.id,
        operation: 'upsert',
        payload: model.toJson(),
      );
      unawaited(_syncEngine.trySync());
      return Right(model);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al guardar participante local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlayer(String id) async {
    try {
      await _local.softDeletePlayer(id);
      await _enqueue(
        table: SupabaseConstants.playersTable,
        rowId: id,
        operation: 'delete',
        payload: null,
      );
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al eliminar participante local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enrollPlayer({
    required String playerId,
    required String tournamentId,
    required String categoryId,
  }) async {
    try {
      final id = PlayerLocalDataSourceImpl.enrollmentId(tournamentId, playerId);
      await _local.upsertEnrollment(
        id: id,
        tournamentId: tournamentId,
        categoryId: categoryId,
        playerId: playerId,
        dirty: true,
      );
      await _enqueue(
        table: SupabaseConstants.enrollmentsTable,
        rowId: id,
        operation: 'upsert',
        payload: {
          'player_id': playerId,
          'tournament_id': tournamentId,
          'category_id': categoryId,
        },
      );
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al inscribir localmente: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unenrollPlayer({
    required String playerId,
    required String tournamentId,
  }) async {
    try {
      final id = PlayerLocalDataSourceImpl.enrollmentId(tournamentId, playerId);
      await _local.softDeleteEnrollment(id);
      await _enqueue(
        table: SupabaseConstants.enrollmentsTable,
        rowId: id,
        operation: 'delete',
        payload: null,
      );
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al desinscribir localmente: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByTournament(
      String tournamentId) async {
    try {
      return Right(await _local.getPlayersByTournament(tournamentId));
    } catch (e) {
      return Left(CacheFailure(
          message: 'Error al leer participantes del torneo: $e'));
    }
  }

  Future<void> _enqueue({
    required String table,
    required String rowId,
    required String operation,
    required Map<String, dynamic>? payload,
  }) {
    return _db.enqueueSyncOp(SyncQueueEntriesCompanion.insert(
      id: const Uuid().v4(),
      entityTable: table,
      rowId: rowId,
      operation: operation,
      payload: Value(payload == null ? null : jsonEncode(payload)),
    ));
  }
}
