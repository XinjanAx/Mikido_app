import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../datasources/fixture_local_datasource.dart';
import '../services/fixture_generator.dart';
import '../services/match_result_service.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final FixtureLocalDataSource _local;
  final AppDatabase _db;
  final SyncEngine _syncEngine;
  final MatchResultService _matchResultService;

  const FixtureRepositoryImpl(
    this._local,
    this._db,
    this._syncEngine,
    this._matchResultService,
  );

  @override
  Future<Either<Failure, List<MatchEntity>>> getMatchesByTournament(
      String tournamentId, {String? categoryId}) async {
    try {
      return Right(await _local.getMatchesByTournament(tournamentId,
          categoryId: categoryId));
    } catch (e) {
      return Left(CacheFailure(message: 'Error al leer partidos locales: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> generateFixture({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
    int timesPlayed = 1,
  }) async {
    try {
      // 1. Eliminar fixture anterior de esta categoría (local + encolar borrado)
      final old = await _local.getMatchesByTournament(tournamentId,
          categoryId: categoryId);
      for (final m in old) {
        await _local.softDelete(m.id);
        await _db.enqueueDelete(SupabaseConstants.matchesTable, m.id);
      }

      // 2. Generar los partidos nuevos (función pura, sin red)
      final newMatches = FixtureGenerator.generate(
        tournamentId: tournamentId,
        categoryId: categoryId,
        mode: mode,
        playerIds: playerIds,
        playerNames: playerNames,
        timesPlayed: timesPlayed,
      );

      // 3. Guardarlos localmente + encolar la subida
      for (final m in newMatches) {
        await _local.upsert(m, dirty: true);
        await _db.enqueueUpsert(
            SupabaseConstants.matchesTable, m.id, m.toJson());
      }

      unawaited(_syncEngine.trySync());
      return Right(newMatches);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al generar el fixture local: $e'));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> updateMatchResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    try {
      final updated = await _matchResultService.applyResult(
        matchId: matchId,
        homeScore: homeScore,
        awayScore: awayScore,
      );
      unawaited(_syncEngine.trySync());
      return Right(updated);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al actualizar resultado local: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFixture(String tournamentId) async {
    try {
      final all = await _local.getMatchesByTournament(tournamentId);
      for (final m in all) {
        await _local.softDelete(m.id);
        await _db.enqueueDelete(SupabaseConstants.matchesTable, m.id);
      }
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al eliminar el fixture local: $e'));
    }
  }

  @override
  Stream<List<MatchEntity>> watchMatches(String tournamentId) =>
      _local.watchMatches(tournamentId);
}
