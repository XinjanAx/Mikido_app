import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/standing_entity.dart';

abstract class StandingRepository {
  Future<Either<Failure, List<StandingEntity>>> getStandings(
      String tournamentId);
  Future<Either<Failure, void>> recalculateStandings(String tournamentId);
  Stream<List<StandingEntity>> watchStandings(String tournamentId);
}
