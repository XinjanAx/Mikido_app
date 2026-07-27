import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_remote_datasource.dart';
import '../models/tournament_model.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource _dataSource;

  const TournamentRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<TournamentEntity>>> getTournaments() async {
    try {
      final result = await _dataSource.getTournaments();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TournamentEntity>> getTournamentById(String id) async {
    try {
      final result = await _dataSource.getTournamentById(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TournamentEntity>> createTournament(
      TournamentEntity tournament) async {
    try {
      final model = TournamentModel.fromEntity(tournament);
      final result = await _dataSource.createTournament(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TournamentEntity>> updateTournament(
      TournamentEntity tournament) async {
    try {
      final model = TournamentModel.fromEntity(tournament);
      final result = await _dataSource.updateTournament(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTournament(String id) async {
    try {
      await _dataSource.deleteTournament(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<List<TournamentEntity>> watchTournaments() =>
      _dataSource.watchTournaments();
}
