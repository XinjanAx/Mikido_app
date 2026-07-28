import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/tournament_local_datasource.dart';
import '../datasources/tournament_remote_datasource.dart';
import '../models/tournament_model.dart';

class TournamentSyncAdapter implements SyncAdapter {
  final TournamentRemoteDataSource _remote;
  final TournamentLocalDataSource _local;

  const TournamentSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.tournamentsTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertTournament(TournamentModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    await _remote.deleteTournament(rowId);
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
    final remoteList = await _remote.getTournaments();
    final remoteIds = remoteList.map((t) => t.id).toSet();

    for (final t in remoteList) {
      if (await _local.isDirty(t.id)) continue;
      await _local.upsert(t, dirty: false);
    }

    // Reflejar localmente los torneos borrados en remoto (por otro
    // dispositivo/admin), salvo que tengan cambios locales pendientes.
    final localList = await _local.getTournaments();
    for (final local in localList) {
      if (!remoteIds.contains(local.id) && !(await _local.isDirty(local.id))) {
        await _local.hardDelete(local.id);
      }
    }
  }
}
