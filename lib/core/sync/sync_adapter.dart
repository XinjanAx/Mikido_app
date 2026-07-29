/// Puente entre el outbox genérico y una entidad concreta (torneos,
/// partidos, etc.). Cada feature offline-first implementa uno.
abstract class SyncAdapter {
  /// Debe coincidir con el nombre de tabla usado en `SyncQueueEntries.entityTable`
  /// (normalmente `SupabaseConstants.xxxTable`).
  String get tableName;

  /// Sube una fila creada/editada localmente. Debe ser idempotente (usar
  /// upsert), ya que puede reintentarse tras un fallo parcial.
  Future<void> pushUpsert(Map<String, dynamic> payload);

  /// Sube un borrado hecho localmente.
  Future<void> pushDelete(String rowId);

  /// Se llama tras subir con éxito: limpia el flag `dirty` local (upsert) o
  /// elimina la fila tombstone local (delete).
  Future<void> markSynced(String rowId, {required bool wasDelete});

  /// Trae todo lo remoto y actualiza la base local, sin pisar filas con
  /// cambios locales pendientes (`dirty`).
  Future<void> pull();
}
