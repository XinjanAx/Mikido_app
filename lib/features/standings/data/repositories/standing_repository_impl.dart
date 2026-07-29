import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/repositories/standing_repository.dart';
import '../datasources/standing_local_datasource.dart';
import '../services/standings_recalculation_service.dart';

class StandingRepositoryImpl implements StandingRepository {
  final StandingLocalDataSource _local;
  final StandingsRecalculationService _recalcService;
  final SyncEngine _syncEngine;

  const StandingRepositoryImpl(
      this._local, this._recalcService, this._syncEngine);

  @override
  Future<Either<Failure, List<StandingEntity>>> getStandings(
      String tournamentId) async {
    try {
      return Right(await _local.getStandings(tournamentId));
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error al leer posiciones locales: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recalculateStandings(
      String tournamentId) async {
    try {
      await _recalcService.recalculate(tournamentId);
      unawaited(_syncEngine.trySync());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Error al recalcular posiciones: $e'));
    }
  }

  @override
  Stream<List<StandingEntity>> watchStandings(String tournamentId) =>
      _local.watchStandings(tournamentId);
}
