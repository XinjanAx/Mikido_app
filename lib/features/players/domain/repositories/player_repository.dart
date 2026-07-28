import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/player_entity.dart';

abstract class PlayerRepository {
  Future<Either<Failure, List<PlayerEntity>>> getPlayers();
  Future<Either<Failure, PlayerEntity>> getPlayerById(String id);
  Future<Either<Failure, PlayerEntity>> createPlayer(PlayerEntity player);
  Future<Either<Failure, PlayerEntity>> updatePlayer(PlayerEntity player);
  Future<Either<Failure, void>> deletePlayer(String id);
  Future<Either<Failure, void>> enrollPlayer({
    required String playerId,
    required String tournamentId,
    required String categoryId,
  });
  Future<Either<Failure, void>> unenrollPlayer({
    required String playerId,
    required String tournamentId,
  });
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByTournament(
      String tournamentId);
}
