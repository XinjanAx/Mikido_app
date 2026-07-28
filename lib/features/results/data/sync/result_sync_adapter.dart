import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/result_local_datasource.dart';
import '../datasources/result_remote_datasource.dart';
import '../models/result_model.dart';

class ResultSyncAdapter implements SyncAdapter {
  final ResultRemoteDataSource _remote;
  final ResultLocalDataSource _local;

  const ResultSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.resultsTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertResult(ResultModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    // No hay flujo de borrado de resultados en la app; se implementa por
    // completitud del contrato de SyncAdapter.
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    await _local.markSynced(rowId);
  }

  @override
  Future<void> pull() async {
    final remoteList = await _remote.getAllResults();
    for (final r in remoteList) {
      if (await _local.isDirty(r.id)) continue;
      await _local.upsert(r, dirty: false);
    }
  }
}
