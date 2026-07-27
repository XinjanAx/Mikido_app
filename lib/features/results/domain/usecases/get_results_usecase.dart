import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/result_entity.dart';
import '../repositories/result_repository.dart';

class GetResultsUseCase {
  final ResultRepository repository;
  const GetResultsUseCase(this.repository);

  Future<Either<Failure, List<ResultEntity>>> call(String tournamentId) =>
      repository.getResultsByTournament(tournamentId);
}

class GetResultByMatchUseCase {
  final ResultRepository repository;
  const GetResultByMatchUseCase(this.repository);

  Future<Either<Failure, ResultEntity?>> call(String matchId) =>
      repository.getResultByMatch(matchId);
}
