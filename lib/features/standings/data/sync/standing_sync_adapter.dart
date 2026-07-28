import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/standing_local_datasource.dart';
import '../datasources/standing_remote_datasource.dart';
import '../models/standing_model.dart';

class StandingSyncAdapter implements SyncAdapter {
  final StandingRemoteDataSource _remote;
  final StandingLocalDataSource _local;

  const StandingSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.standingsTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertStanding(StandingModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    // No hay flujo de borrado de posiciones en la app; se implementa por
    // completitud del contrato de SyncAdapter.
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    await _local.markSynced(rowId);
  }

  @override
  Future<void> pull() async {
    final remoteList = await _remote.getAllStandings();
    for (final s in remoteList) {
      if (await _local.isDirty(s.id)) continue;
      await _local.upsert(s, dirty: false);
    }
  }
}
