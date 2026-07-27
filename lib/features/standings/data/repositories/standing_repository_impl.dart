import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/repositories/standing_repository.dart';
import '../datasources/standing_remote_datasource.dart';

class StandingRepositoryImpl implements StandingRepository {
  final StandingRemoteDataSource _dataSource;
  const StandingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<StandingEntity>>> getStandings(
      String tournamentId, {String? categoryId}) async {
    try {
      return Right(await _dataSource.getStandings(tournamentId,
          categoryId: categoryId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> recalculateStandings(
      String tournamentId) async {
    try {
      await _dataSource.recalculateStandings(tournamentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Stream<List<StandingEntity>> watchStandings(String tournamentId) =>
      _dataSource.watchStandings(tournamentId);
}
