import 'package:drift/drift.dart';

/// Inscripción de un jugador a una categoría de un torneo.
/// [id] es sintético (`'tournamentId:playerId'`) para tener una clave
/// primaria simple, consistente con el resto del esquema.
class Enrollments extends Table {
  TextColumn get id => text()();
  TextColumn get tournamentId => text()();
  TextColumn get categoryId => text()();
  TextColumn get playerId => text()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get deletedLocally =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
