import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/sync/category_sync_adapter.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/category_usecases.dart';

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>(
  (ref) => CategoryRemoteDataSourceImpl(Supabase.instance.client),
);

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>(
  (ref) => CategoryLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final categorySyncAdapterProvider = Provider<CategorySyncAdapter>(
  (ref) => CategorySyncAdapter(
    ref.watch(categoryRemoteDataSourceProvider),
    ref.watch(categoryLocalDataSourceProvider),
  ),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(
    ref.watch(categoryLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  ),
);
final getCategoriesUseCaseProvider = Provider(
  (ref) => GetCategoriesUseCase(ref.watch(categoryRepositoryProvider)),
);
final createCategoryUseCaseProvider = Provider(
  (ref) => CreateCategoryUseCase(ref.watch(categoryRepositoryProvider)),
);
final deleteCategoryUseCaseProvider = Provider(
  (ref) => DeleteCategoryUseCase(ref.watch(categoryRepositoryProvider)),
);

class CategoriesState {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoriesState copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    String? errorMessage,
  }) =>
      CategoriesState(
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final GetCategoriesUseCase _getAll;
  final CreateCategoryUseCase _create;
  final DeleteCategoryUseCase _delete;
  final String tournamentId;

  CategoriesNotifier({
    required GetCategoriesUseCase getAll,
    required CreateCategoryUseCase create,
    required DeleteCategoryUseCase delete,
    required this.tournamentId,
  })  : _getAll = getAll,
        _create = create,
        _delete = delete,
        super(const CategoriesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final result = await _getAll(tournamentId);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (list) => state = state.copyWith(isLoading: false, categories: list),
    );
  }

  Future<bool> createCategory({required String name, String? description}) async {
    final cat = CategoryEntity(
      id: const Uuid().v4(),
      name: name,
      tournamentId: tournamentId,
      description: description,
    );
    final result = await _create(cat);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (created) {
        state = state.copyWith(categories: [...state.categories, created]);
        return true;
      },
    );
  }

  Future<bool> deleteCategory(String id) async {
    final result = await _delete(id);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          categories: state.categories.where((c) => c.id != id).toList(),
        );
        return true;
      },
    );
  }
}

// Family provider por tournamentId
final categoriesProvider = StateNotifierProvider.family<CategoriesNotifier,
    CategoriesState, String>(
  (ref, tournamentId) => CategoriesNotifier(
    getAll: ref.watch(getCategoriesUseCaseProvider),
    create: ref.watch(createCategoryUseCaseProvider),
    delete: ref.watch(deleteCategoryUseCaseProvider),
    tournamentId: tournamentId,
  ),
);
