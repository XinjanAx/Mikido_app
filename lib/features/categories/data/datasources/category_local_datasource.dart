import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategoriesByTournament(String tournamentId);
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> upsert(CategoryModel category, {required bool dirty});
  Future<bool> isDirty(String id);
  Future<void> markSynced(String id);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final AppDatabase _db;
  const CategoryLocalDataSourceImpl(this._db);

  CategoryModel _toModel(Category row) => CategoryModel(
        id: row.id,
        name: row.name,
        tournamentId: row.tournamentId,
        description: row.description,
        minAge: row.minAge,
        maxAge: row.maxAge,
        maxParticipants: row.maxParticipants,
        createdAt: row.createdAt,
      );

  @override
  Future<List<CategoryModel>> getCategoriesByTournament(
          String tournamentId) async =>
      (await _db.getCategoriesByTournament(tournamentId))
          .map(_toModel)
          .toList();

  @override
  Future<List<CategoryModel>> getAllCategories() async =>
      (await _db.getAllCategoriesLocal()).map(_toModel).toList();

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final row = await _db.getCategoryById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> upsert(CategoryModel category, {required bool dirty}) {
    return _db.upsertCategory(CategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      tournamentId: category.tournamentId,
      description: Value(category.description),
      minAge: Value(category.minAge),
      maxAge: Value(category.maxAge),
      maxParticipants: Value(category.maxParticipants),
      createdAt: Value(category.createdAt),
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isDirty(String id) async {
    final row = await _db.getCategoryById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markSynced(String id) => _db.clearCategoryDirty(id);

  @override
  Future<void> softDelete(String id) => _db.softDeleteCategory(id);

  @override
  Future<void> hardDelete(String id) => _db.hardDeleteCategory(id);
}
