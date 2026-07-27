import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/player_remote_datasource.dart';
import '../models/player_model.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerRemoteDataSource _dataSource;
  const PlayerRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayers() async {
    try {
      return Right(await _dataSource.getPlayers());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> getPlayerById(String id) async {
    try {
      return Right(await _dataSource.getPlayerById(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> createPlayer(
      PlayerEntity player) async {
    try {
      return Right(
          await _dataSource.createPlayer(PlayerModel.fromEntity(player)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updatePlayer(
      PlayerEntity player) async {
    try {
      return Right(
          await _dataSource.updatePlayer(PlayerModel.fromEntity(player)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlayer(String id) async {
    try {
      await _dataSource.deletePlayer(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> enrollPlayer({
    required String playerId,
    required String tournamentId,
    required String categoryId,
  }) async {
    try {
      await _dataSource.enrollPlayer(
        playerId: playerId,
        tournamentId: tournamentId,
        categoryId: categoryId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getPlayersByTournament(
      String tournamentId) async {
    try {
      return Right(await _dataSource.getPlayersByTournament(tournamentId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
