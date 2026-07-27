import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategoriesByTournament(
      String tournamentId);
  Future<Either<Failure, CategoryEntity>> createCategory(CategoryEntity category);
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String id);
}
