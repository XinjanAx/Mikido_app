import 'package:drift/drift.dart';

/// Réplica local de la tabla `mesas` de Supabase. Una mesa es el lugar
/// físico (cancha, pista, tatami, ring o plataforma) donde se disputan los
/// encuentros de una o varias categorías, con un orden global propio
/// (ver `Matches.mesaOrder`).
class Mesas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
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
