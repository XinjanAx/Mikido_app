import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/result_entity.dart';

abstract class ResultRepository {
  Future<Either<Failure, ResultEntity>> registerResult({
    required String matchId,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    required String registeredBy,
    String? notes,
  });

  Future<Either<Failure, List<ResultEntity>>> getResultsByTournament(
      String tournamentId);

  Future<Either<Failure, ResultEntity?>> getResultByMatch(String matchId);
}
