import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/result_repository.dart';
import '../datasources/result_remote_datasource.dart';

class ResultRepositoryImpl implements ResultRepository {
  final ResultRemoteDataSource _dataSource;
  const ResultRepositoryImpl(this._dataSource);

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
      final result = await _dataSource.registerResult(
        matchId: matchId,
        tournamentId: tournamentId,
        homePlayerId: homePlayerId,
        awayPlayerId: awayPlayerId,
        homeScore: homeScore,
        awayScore: awayScore,
        registeredBy: registeredBy,
        notes: notes,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ResultEntity>>> getResultsByTournament(
      String tournamentId) async {
    try {
      return Right(
          await _dataSource.getResultsByTournament(tournamentId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ResultEntity?>> getResultByMatch(
      String matchId) async {
    try {
      return Right(await _dataSource.getResultByMatch(matchId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
