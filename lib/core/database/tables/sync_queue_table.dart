import 'package:drift/drift.dart';

/// Cola de mutaciones pendientes de subir a Supabase (outbox).
/// Cada fila representa un cambio hecho localmente sin conexión que el
/// [SyncEngine] debe reproducir contra el backend cuando vuelva la señal.
class SyncQueueEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entityTable => text()();
  TextColumn get rowId => text()();

  /// 'upsert' | 'delete'
  TextColumn get operation => text()();

  /// JSON con los datos de la fila (solo aplica para 'upsert').
  TextColumn get payload => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
