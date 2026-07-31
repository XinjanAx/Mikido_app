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
    for (final t in remoteList) {
      if (await _local.isDirty(t.id)) continue;
      await _local.upsert(t, dirty: false);
    }

    // Propaga borrados hechos en OTRO dispositivo: si un torneo local ya
    // sincronizado (no dirty) no aparece en la traída remota, se borró de
    // verdad en otro lado. Antes esto borraba directo por "no aparece en
    // esta traída", pero una traída vacía o parcial (red inestable,
    // timing en el arranque) hacía lo mismo por error y borraba datos
    // reales sin aviso. La salvaguarda `remoteList.isNotEmpty` evita
    // exactamente ese caso: nunca se interpreta una traída vacía como
    // "se borró todo" (el único costo es que borrar el ÚLTIMO torneo
    // restante no se propaga solo — hay que borrarlo también a mano en
    // cada dispositivo, un caso raro comparado con perder datos reales).
    if (remoteList.isNotEmpty) {
      final remoteIds = remoteList.map((t) => t.id).toSet();
      final localList = await _local.getTournaments();
      for (final local in localList) {
        if (remoteIds.contains(local.id)) continue;
        if (await _local.isDirty(local.id)) continue;
        await _local.hardDelete(local.id);
      }
    }
  }
}
