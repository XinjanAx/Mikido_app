import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/fixture_local_datasource.dart';
import '../datasources/fixture_remote_datasource.dart';
import '../models/match_model.dart';

class FixtureSyncAdapter implements SyncAdapter {
  final FixtureRemoteDataSource _remote;
  final FixtureLocalDataSource _local;

  const FixtureSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.matchesTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertMatch(MatchModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    await _remote.deleteMatch(rowId);
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
    final remoteList = await _remote.getAllMatches();
    final remoteIds = remoteList.map((m) => m.id).toSet();

    for (final m in remoteList) {
      if (await _local.isDirty(m.id)) continue;
      await _local.upsert(m, dirty: false);
    }

    final localList = await _local.getAllMatches();
    for (final local in localList) {
      if (!remoteIds.contains(local.id) && !(await _local.isDirty(local.id))) {
        await _local.hardDelete(local.id);
      }
    }
  }
}
