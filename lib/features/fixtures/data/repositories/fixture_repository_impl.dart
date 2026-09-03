import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../tournaments/data/datasources/tournament_local_datasource.dart';
import '../../../tournaments/data/models/tournament_model.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../datasources/fixture_local_datasource.dart';
import '../datasources/fixture_remote_datasource.dart';
import '../services/fixture_generator.dart';
import '../services/match_result_service.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final FixtureLocalDataSource _local;
  final FixtureRemoteDataSource _remote;
  final AppDatabase _db;
  final SyncEngine _syncEngine;
  final MatchResultService _matchResultService;
  final TournamentLocalDataSource _tournaments;

  const FixtureRepositoryImpl(
    this._local,
    this._remote,
    this._db,
    this._syncEngine,
    this._matchResultService,
    this._tournaments,
  );

  /// Borra todos los partidos de un torneo: soft-delete local + outbox
  /// (offline-first, como siempre) MÁS un borrado remoto directo e
  /// inmediato. El outbox solo puede fallar en silencio o tardar en
  /// sincronizar — si eso pasa, la fila vieja queda viva en Supabase y el
  /// próximo `pull()` la resucita localmente como si fuera nueva,
  /// mezclando la llave anterior con la que se regenere después. El
  /// borrado remoto directo no depende de esa espera, así que evita ese
  /// fantasma incluso si el outbox nunca llega a drenarse.
  Future<void> _wipeMatches(String tournamentId) async {
    final old = await _local.getMatchesByTournament(tournamentId);
    for (final m in old) {
      await _local.softDelete(m.id);
      await _db.enqueueDelete(SupabaseConstants.matchesTable, m.id);
    }
    if (old.isEmpty) return;
    try {
      await _remote.deleteMatchesByTournament(tournamentId);
    } catch (_) {
      // Sin red o error remoto: no bloquea el flujo local, el outbox ya
      // encoló el borrado y lo reintentará en el próximo sync.
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> getMatchesByTournament(
      String tournamentId) async {
    try {
      return Right(await _local.getMatchesByTournament(tournamentId));
    } catch (e) {
      return Left(CacheFailure(message: 'Error al leer partidos locales: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> generateFixture({
    required String tournamentId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
    int timesPlayed = 1,
    int numberOfGroups = 0,
    List<List<String>>? manualGroups,
    List<String>? manualBracketOrder,
  }) async {
    try {
      // 1. Eliminar fixture anterior del torneo
      await _wipeMatches(tournamentId);

      // 2. Generar los partidos nuevos (función pura, sin red)
      final newMatches = FixtureGenerator.generate(
        tournamentId: tournamentId,
        mode: mode,
        playerIds: playerIds,
        playerNames: playerNames,
        timesPlayed: timesPlayed,
        numberOfGroups: numberOfGroups,
        manualGroups: manualGroups,
        manualBracketOrder: manualBracketOrder,
      );

      // 3. Guardarlos localmente + encolar la subida
      for (final m in newMatches) {
        await _local.upsert(m, dirty: true);
        await _db.enqueueUpsert(
            SupabaseConstants.matchesTable, m.id, m.toJson());
      }

      // 4. Un torneo con encuentros generados ya no está en borrador: pasa
      // solo a "Activo" (no hace falta que el admin lo cambie a mano).
      if (newMatches.isNotEmpty) {
        await _activateIfDraft(tournamentId);
      }

      unawaited(_syncEngine.trySync());
      return Right(newMatches);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al generar los encuentros localmente: $e'));
    }
  }

  /// Si el torneo sigue en borrador, lo pasa a "Activo" — se llama justo
  /// después de generar encuentros por primera vez (ver `generateFixture`).
  Future<void> _activateIfDraft(String tournamentId) async {
    final tournament = await _tournaments.getTournamentById(tournamentId);
    if (tournament == null || tournament.status != AppConstants.statusDraft) {
      return;
    }
    final updated = TournamentModel(
      id: tournament.id,
      name: tournament.name,
      mode: tournament.mode,
      status: AppConstants.statusActive,
      description: tournament.description,
      startDate: tournament.startDate,
      endDate: tournament.endDate,
      createdBy: tournament.createdBy,
      createdAt: tournament.createdAt,
    );
    await _tournaments.upsert(updated, dirty: true);
    await _db.enqueueUpsert(
        SupabaseConstants.tournamentsTable, updated.id, updated.toJson());
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
      await _wipeMatches(tournamentId);
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al eliminar los encuentros localmente: $e'));
    }
  }

  @override
  Stream<List<MatchEntity>> watchMatches(String tournamentId) =>
      _local.watchMatches(tournamentId);
}
