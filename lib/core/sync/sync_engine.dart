import 'dart:convert';

import '../database/app_database.dart';
import 'sync_adapter.dart';

/// Motor genérico de sincronización offline-first.
///
/// - [trySync] primero drena el outbox (sube cambios locales pendientes en
///   orden), y luego pide a cada adapter que traiga lo remoto.
/// - No conoce nada específico de un feature: solo conversa con
///   [SyncAdapter]s registrados por tabla.
/// - Limitación aceptada: si una operación del outbox falla repetidamente
///   (p. ej. datos inválidos), se reintenta indefinidamente en cada
///   [trySync] sin bloquear al resto de la cola.
class SyncEngine {
  final AppDatabase _db;
  final List<SyncAdapter> _adapters;
  bool _isSyncing = false;

  SyncEngine(this._db, this._adapters);

  Future<void> trySync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _pushOutbox();
      for (final adapter in _adapters) {
        try {
          await adapter.pull();
        } catch (_) {
          // Sin red o error remoto: seguimos con lo que haya en local.
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushOutbox() async {
    final byTable = {for (final a in _adapters) a.tableName: a};
    final pending = await _db.pendingSyncOps();

    for (final op in pending) {
      final adapter = byTable[op.entityTable];
      if (adapter == null) continue;
      try {
        if (op.operation == 'delete') {
          await adapter.pushDelete(op.rowId);
          await adapter.markSynced(op.rowId, wasDelete: true);
        } else {
          final payload = jsonDecode(op.payload!) as Map<String, dynamic>;
          await adapter.pushUpsert(payload);
          await adapter.markSynced(op.rowId, wasDelete: false);
        }
        await _db.removeSyncOp(op.id);
      } catch (e) {
        await _db.markSyncOpFailed(op.id, op.retryCount + 1, e.toString());
      }
    }
  }
}
