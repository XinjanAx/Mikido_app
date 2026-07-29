import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/standing_entity.dart';
import '../repositories/standing_repository.dart';

class GetStandingsUseCase {
  final StandingRepository repository;
  const GetStandingsUseCase(this.repository);

  Future<Either<Failure, List<StandingEntity>>> call(String tournamentId) =>
      repository.getStandings(tournamentId);
}

class RecalculateStandingsUseCase {
  final StandingRepository repository;
  const RecalculateStandingsUseCase(this.repository);

  Future<Either<Failure, void>> call(String tournamentId) =>
      repository.recalculateStandings(tournamentId);
}
