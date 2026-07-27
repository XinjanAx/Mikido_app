import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/result_entity.dart';
import '../repositories/result_repository.dart';

class RegisterResultUseCase {
  final ResultRepository repository;
  const RegisterResultUseCase(this.repository);

  Future<Either<Failure, ResultEntity>> call({
    required String matchId,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    required String registeredBy,
    String? notes,
  }) =>
      repository.registerResult(
        matchId: matchId,
        tournamentId: tournamentId,
        homePlayerId: homePlayerId,
        awayPlayerId: awayPlayerId,
        homeScore: homeScore,
        awayScore: awayScore,
        registeredBy: registeredBy,
        notes: notes,
      );
}
