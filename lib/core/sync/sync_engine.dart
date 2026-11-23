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

  /// Sincronización en curso, si la hay.
  Future<void>? _running;

  SyncEngine(this._db, this._adapters);

  /// Sincroniza. Si ya hay una sincronización en curso NO arranca otra:
  /// devuelve esa misma, así quien llama puede esperarla (p. ej. el splash
  /// espera la sincronización inicial que ya disparó syncTriggerProvider).
  Future<void> trySync() {
    return _running ??= _sync().whenComplete(() => _running = null);
  }

  Future<void> _sync() async {
    await _pushOutbox();
    for (final adapter in _adapters) {
      try {
        await adapter.pull();
      } catch (_) {
        // Sin red o error remoto: seguimos con lo que haya en local.
      }
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
