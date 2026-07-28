import 'package:drift/drift.dart';

/// Réplica local de la tabla `tournaments` de Supabase, con columnas extra
/// de control para el motor de sincronización offline.
class Tournaments extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get mode => text()();
  TextColumn get status => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// true = hay cambios locales que aún no se subieron a Supabase.
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  /// Tombstone: se borró localmente pero aún no se confirmó el borrado remoto.
  BoolColumn get deletedLocally =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
