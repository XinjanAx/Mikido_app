import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/player_local_datasource.dart';
import '../datasources/player_remote_datasource.dart';
import '../models/player_model.dart';

class PlayerSyncAdapter implements SyncAdapter {
  final PlayerRemoteDataSource _remote;
  final PlayerLocalDataSource _local;

  const PlayerSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.playersTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertPlayer(PlayerModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    await _remote.deletePlayer(rowId);
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    if (wasDelete) {
      await _local.hardDeletePlayer(rowId);
    } else {
      await _local.markPlayerSynced(rowId);
    }
  }

  @override
  Future<void> pull() async {
    final remoteList = await _remote.getPlayers();
    for (final p in remoteList) {
      if (await _local.isPlayerDirty(p.id)) continue;
      await _local.upsertPlayer(p, dirty: false);
    }

    // Propaga borrados hechos en OTRO dispositivo (con la misma
    // salvaguarda de no actuar sobre una traída vacía — ver
    // TournamentSyncAdapter.pull() para la explicación completa).
    if (remoteList.isNotEmpty) {
      final remoteIds = remoteList.map((p) => p.id).toSet();
      final localList = await _local.getPlayers();
      for (final local in localList) {
        if (remoteIds.contains(local.id)) continue;
        if (await _local.isPlayerDirty(local.id)) continue;
        await _local.hardDeletePlayer(local.id);
      }
    }
  }
}
