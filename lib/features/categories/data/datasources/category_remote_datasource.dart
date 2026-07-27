import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategoriesByTournament(String tournamentId);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
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
}
