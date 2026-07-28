import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/player_entity.dart';
import '../repositories/player_repository.dart';

class GetPlayersUseCase {
  final PlayerRepository repository;
  const GetPlayersUseCase(this.repository);
  Future<Either<Failure, List<PlayerEntity>>> call() => repository.getPlayers();
}

class GetPlayersByTournamentUseCase {
  final PlayerRepository repository;
  const GetPlayersByTournamentUseCase(this.repository);
  Future<Either<Failure, List<PlayerEntity>>> call(String tournamentId) =>
      repository.getPlayersByTournament(tournamentId);
}

class CreatePlayerUseCase {
  final PlayerRepository repository;
  const CreatePlayerUseCase(this.repository);
  Future<Either<Failure, PlayerEntity>> call(PlayerEntity player) =>
      repository.createPlayer(player);
}

class UpdatePlayerUseCase {
  final PlayerRepository repository;
  const UpdatePlayerUseCase(this.repository);
  Future<Either<Failure, PlayerEntity>> call(PlayerEntity player) =>
      repository.updatePlayer(player);
}

class DeletePlayerUseCase {
  final PlayerRepository repository;
  const DeletePlayerUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) => repository.deletePlayer(id);
}

class EnrollPlayerUseCase {
  final PlayerRepository repository;
  const EnrollPlayerUseCase(this.repository);
  Future<Either<Failure, void>> call({
    required String playerId,
    required String tournamentId,
    required String categoryId,
  }) =>
      repository.enrollPlayer(
        playerId: playerId,
        tournamentId: tournamentId,
        categoryId: categoryId,
      );
}

class UnenrollPlayerUseCase {
  final PlayerRepository repository;
  const UnenrollPlayerUseCase(this.repository);
  Future<Either<Failure, void>> call({
    required String playerId,
    required String tournamentId,
  }) =>
      repository.unenrollPlayer(playerId: playerId, tournamentId: tournamentId);
}
