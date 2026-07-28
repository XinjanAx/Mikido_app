import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategorySyncAdapter implements SyncAdapter {
  final CategoryRemoteDataSource _remote;
  final CategoryLocalDataSource _local;

  const CategorySyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.categoriesTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertCategory(CategoryModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    await _remote.deleteCategory(rowId);
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    if (wasDelete) {
      await _local.hardDelete(rowId);
    } else {
      await _local.markSynced(rowId);
    }
  }

  @override
  Future<void> pull() async {
    final remoteList = await _remote.getAllCategories();
    final remoteIds = remoteList.map((c) => c.id).toSet();

    for (final c in remoteList) {
      if (await _local.isDirty(c.id)) continue;
      await _local.upsert(c, dirty: false);
    }

    final localList = await _local.getAllCategories();
    for (final local in localList) {
      if (!remoteIds.contains(local.id) && !(await _local.isDirty(local.id))) {
        await _local.hardDelete(local.id);
      }
    }
  }
}
