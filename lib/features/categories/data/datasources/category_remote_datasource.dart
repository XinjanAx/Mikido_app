import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategoriesByTournament(String tournamentId);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);

  /// Todas las categorías (todos los torneos), usado por el motor de
  /// sincronización para reconciliar la base local.
  Future<List<CategoryModel>> getAllCategories();

  /// Upsert idempotente usado por el motor de sincronización.
  Future<CategoryModel> upsertCategory(CategoryModel category);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final SupabaseClient _client;
  const CategoryRemoteDataSourceImpl(this._client);

  @override
  Future<List<CategoryModel>> getCategoriesByTournament(
      String tournamentId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.categoriesTable)
          .select()
          .eq('tournament_id', tournamentId)
          .order('name');
      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener categorías: $e');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final data = await _client
          .from(SupabaseConstants.categoriesTable)
          .insert(category.toInsertJson())
          .select()
          .single();
      return CategoryModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al crear categoría: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final data = await _client
          .from(SupabaseConstants.categoriesTable)
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();
      return CategoryModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar categoría: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _client
          .from(SupabaseConstants.categoriesTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar categoría: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final data =
          await _client.from(SupabaseConstants.categoriesTable).select();
      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener categorías: $e');
    }
  }

  @override
  Future<CategoryModel> upsertCategory(CategoryModel category) async {
    try {
      final data = await _client
          .from(SupabaseConstants.categoriesTable)
          .upsert(category.toJson())
          .select()
          .single();
      return CategoryModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar categoría: $e');
    }
  }
}
