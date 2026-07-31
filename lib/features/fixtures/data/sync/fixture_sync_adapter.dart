import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/fixture_local_datasource.dart';
import '../datasources/fixture_remote_datasource.dart';
import '../models/match_model.dart';

class FixtureSyncAdapter implements SyncAdapter {
  final FixtureRemoteDataSource _remote;
  final FixtureLocalDataSource _local;

  const FixtureSyncAdapter(
    this._remote,
    this._local,
  );

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
    for (final m in remoteList) {
      if (await _local.isDirty(m.id)) continue;
      await _local.upsert(m, dirty: false);
    }

    // Propaga borrados hechos en OTRO dispositivo (p. ej. "Eliminar
    // encuentros"), con la misma salvaguarda de no actuar sobre una
    // traída vacía — ver TournamentSyncAdapter.pull() para la
    // explicación completa.
    if (remoteList.isNotEmpty) {
      final remoteIds = remoteList.map((m) => m.id).toSet();
      final localList = await _local.getAllMatches();
      for (final local in localList) {
        if (remoteIds.contains(local.id)) continue;
        if (await _local.isDirty(local.id)) continue;
        await _local.hardDelete(local.id);
      }
    }

    // El avance de ronda de eliminación YA NO se dispara nunca en
    // segundo plano — solo lo hace la UI (ver EliminationBracketService
    // + match_result_service.dart), y siempre con confirmación explícita
    // del admin. Antes esto reintentaba avanzar aquí en cada sync para
    // cubrir el caso de dos admins completando la misma ronda en
    // dispositivos distintos, pero eso también podía disparar el avance
    // usando un resultado que un admin recién había corregido en su
    // propio dispositivo mientras esperaba confirmar — pasando al
    // competidor equivocado sin preguntar. En el caso multi-dispositivo,
    // la ronda queda pendiente hasta que alguien la confirme desde
    // cualquier dispositivo (al guardar/corregir cualquier resultado de
    // esa ronda, ya con los datos sincronizados).
  }
}
