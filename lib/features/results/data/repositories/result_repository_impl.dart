import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../fixtures/data/services/match_result_service.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/result_repository.dart';
import '../datasources/result_local_datasource.dart';
import '../models/result_model.dart';

class ResultRepositoryImpl implements ResultRepository {
  final ResultLocalDataSource _local;
  final AppDatabase _db;
  final SyncEngine _syncEngine;
  final MatchResultService _matchResultService;

  const ResultRepositoryImpl(
    this._local,
    this._db,
    this._syncEngine,
    this._matchResultService,
  );

  @override
  Future<Either<Failure, ResultEntity>> registerResult({
    required String matchId,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    required String registeredBy,
    String? notes,
  }) async {
    try {
      // 1. Actualizar el partido + recalcular posiciones + avanzar bracket
      // si el torneo es de eliminación (mismo camino que Fixtures usa).
      await _matchResultService.applyResult(
        matchId: matchId,
        homeScore: homeScore,
        awayScore: awayScore,
      );

      // 2. Guardar el registro de resultado. Reutiliza el id existente para
      // este partido si ya se había registrado antes, para no duplicar.
      final existing = await _local.getResultByMatch(matchId);
      final model = ResultModel(
        id: existing?.id ?? const Uuid().v4(),
        matchId: matchId,
        tournamentId: tournamentId,
        homePlayerId: homePlayerId,
        awayPlayerId: awayPlayerId,
        homeScore: homeScore,
        awayScore: awayScore,
        notes: notes,
        registeredBy: registeredBy,
        registeredAt: DateTime.now(),
      );
      await _local.upsert(model, dirty: true);
      await _db.enqueueUpsert(
          SupabaseConstants.resultsTable, model.id, model.toJson());

      unawaited(_syncEngine.trySync());
      return Right(model);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al registrar resultado local: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ResultEntity>>> getResultsByTournament(
      String tournamentId) async {
    try {
      return Right(await _local.getResultsByTournament(tournamentId));
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al leer resultados locales: $e'));
    }
  }

  @override
  Future<Either<Failure, ResultEntity?>> getResultByMatch(
      String matchId) async {
    try {
      return Right(await _local.getResultByMatch(matchId));
    } catch (e) {
      return Left(CacheFailure(message: 'Error al leer resultado local: $e'));
    }
  }
}
