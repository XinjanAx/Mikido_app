import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/mesa_local_datasource.dart';
import '../datasources/mesa_remote_datasource.dart';
import '../models/mesa_model.dart';

class MesaSyncAdapter implements SyncAdapter {
  final MesaRemoteDataSource _remote;
  final MesaLocalDataSource _local;

  /// Mesas cuyo borrado rechazó el servidor en este ciclo (ver [pushDelete]).
  final Set<String> _rejectedDeletes = {};

  MesaSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.mesasTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) =>
      _remote.upsertMesa(MesaModel.fromJson(payload));

  /// Si el borrado se hizo con datos locales desactualizados (el
  /// dispositivo creía la mesa vacía pero en el servidor tiene categorías),
  /// Supabase lo rechaza. En vez de dejar la operación reintentándose para
  /// siempre con la mesa oculta en este dispositivo —y sus categorías
  /// invisibles con ella—, se deshace el borrado local y la operación se
  /// da por terminada: la mesa vuelve a aparecer.
  @override
  Future<void> pushDelete(String rowId) async {
    try {
      await _remote.deleteMesa(rowId);
    } on StillReferencedException {
      await _local.restore(rowId);
      _rejectedDeletes.add(rowId);
    }
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    if (wasDelete) {
      if (_rejectedDeletes.remove(rowId)) return; // borrado rechazado
      await _local.hardDelete(rowId);
    } else {
      await _local.markSynced(rowId);
    }
  }

  @override
  Future<void> pull() async {
    final remoteList = await _remote.getMesas();
    for (final m in remoteList) {
      if (await _local.isDirty(m.id)) continue;
      await _local.upsert(m, dirty: false);
    }

    // Propaga borrados de otro dispositivo, sin actuar sobre una traída
    // vacía (ver TournamentSyncAdapter.pull()).
    if (remoteList.isNotEmpty) {
      final remoteIds = remoteList.map((m) => m.id).toSet();
      for (final local in await _local.getMesas()) {
        if (remoteIds.contains(local.id)) continue;
        if (await _local.isDirty(local.id)) continue;
        await _local.hardDelete(local.id);
      }
    }
  }
}
