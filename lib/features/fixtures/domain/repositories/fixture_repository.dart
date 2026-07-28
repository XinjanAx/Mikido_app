import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/match_entity.dart';

abstract class FixtureRepository {
  Future<Either<Failure, List<MatchEntity>>> getMatchesByTournament(
      String tournamentId, {String? categoryId});
  Future<Either<Failure, List<MatchEntity>>> generateFixture({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
    int timesPlayed = 1,
  });
  Future<Either<Failure, MatchEntity>> updateMatchResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  });
  Future<Either<Failure, void>> deleteFixture(String tournamentId);
  Stream<List<MatchEntity>> watchMatches(String tournamentId);
}
