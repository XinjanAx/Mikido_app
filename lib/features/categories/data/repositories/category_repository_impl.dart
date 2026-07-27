import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _dataSource;
  const CategoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByTournament(
      String tournamentId) async {
    try {
      return Right(await _dataSource.getCategoriesByTournament(tournamentId));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(
      CategoryEntity category) async {
    try {
      return Right(await _dataSource
          .createCategory(CategoryModel.fromEntity(category)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
      CategoryEntity category) async {
    try {
      return Right(await _dataSource
          .updateCategory(CategoryModel.fromEntity(category)));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _dataSource.deleteCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
