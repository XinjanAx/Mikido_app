import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;
  const GetCategoriesUseCase(this.repository);
  Future<Either<Failure, List<CategoryEntity>>> call(String tournamentId) =>
      repository.getCategoriesByTournament(tournamentId);
}

class CreateCategoryUseCase {
  final CategoryRepository repository;
  const CreateCategoryUseCase(this.repository);
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) =>
      repository.createCategory(category);
}

class UpdateCategoryUseCase {
  final CategoryRepository repository;
  const UpdateCategoryUseCase(this.repository);
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) =>
      repository.updateCategory(category);
}

class DeleteCategoryUseCase {
  final CategoryRepository repository;
  const DeleteCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteCategory(id);
}
