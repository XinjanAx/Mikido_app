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
    // Solo agrega/actualiza desde lo remoto — nunca borra localmente por
    // "no aparece en esta traída". Antes borraba los torneos locales que
    // no estuvieran en `remoteList`, pero una traída remota vacía o
    // parcial (red inestable, timing en el arranque, etc.) borraba datos
    // reales igual: sin excepción, sin aviso, y sin volver nunca solo.
    // Un torneo borrado de verdad en otro dispositivo se sigue viendo acá
    // hasta que se borre explícitamente también en este — mejor eso que
    // perder datos activos por una lectura incompleta.
    final remoteList = await _remote.getTournaments();
    for (final t in remoteList) {
      if (await _local.isDirty(t.id)) continue;
      await _local.upsert(t, dirty: false);
    }
  }
}
