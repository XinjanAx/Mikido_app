import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../datasources/fixture_remote_datasource.dart';

class FixtureRepositoryImpl implements FixtureRepository {
  final FixtureRemoteDataSource _dataSource;
  const FixtureRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<MatchEntity>>> getMatchesByTournament(
      String tournamentId, {String? categoryId}) async {
    try {
      return Right(await _dataSource.getMatchesByTournament(
          tournamentId, categoryId: categoryId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<MatchEntity>>> generateFixture({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
  }) async {
    try {
      return Right(await _dataSource.generateFixture(
        tournamentId: tournamentId,
        categoryId: categoryId,
        mode: mode,
        playerIds: playerIds,
        playerNames: playerNames,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> updateMatchResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    try {
      return Right(await _dataSource.updateMatchResult(
        matchId: matchId,
        homeScore: homeScore,
        awayScore: awayScore,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<List<MatchEntity>> watchMatches(String tournamentId) =>
      _dataSource.watchMatches(tournamentId);
}
