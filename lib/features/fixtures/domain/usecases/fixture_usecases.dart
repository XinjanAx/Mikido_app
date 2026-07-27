import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../entities/match_entity.dart';
import '../repositories/fixture_repository.dart';

class GetMatchesUseCase {
  final FixtureRepository repository;
  const GetMatchesUseCase(this.repository);
  Future<Either<Failure, List<MatchEntity>>> call(
    String tournamentId, {
    String? categoryId,
  }) =>
      repository.getMatchesByTournament(tournamentId, categoryId: categoryId);
}

class GenerateFixtureUseCase {
  final FixtureRepository repository;
  const GenerateFixtureUseCase(this.repository);

  /// Genera el fixture según la modalidad:
  /// - groups: todos contra todos dentro de grupos
  /// - elimination: cuadro eliminatorio directo
  /// - league: todos contra todos (round-robin completo)
  Future<Either<Failure, List<MatchEntity>>> call({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
  }) {
    _validateInputs(playerIds, mode);
    return repository.generateFixture(
      tournamentId: tournamentId,
      categoryId: categoryId,
      mode: mode,
      playerIds: playerIds,
      playerNames: playerNames,
    );
  }

  void _validateInputs(List<String> playerIds, String mode) {
    if (playerIds.length < 2) {
      throw ArgumentError('Se necesitan al menos 2 participantes');
    }
    if (mode == AppConstants.tournamentModeElimination) {
      // Para eliminación simple, recomendamos potencia de 2
      // pero no es obligatorio (bye automático)
    }
  }
}

class UpdateMatchResultUseCase {
  final FixtureRepository repository;
  const UpdateMatchResultUseCase(this.repository);

  Future<Either<Failure, MatchEntity>> call({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) =>
      repository.updateMatchResult(
        matchId: matchId,
        homeScore: homeScore,
        awayScore: awayScore,
      );
}
