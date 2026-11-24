import 'package:drift/drift.dart';

class Players extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get photoUrl => text().nullable()();

  /// Gremio o clan (opcional) y su acrónimo (máx. 4 letras, en mayúsculas;
  /// obligatorio solo si hay gremio).
  TextColumn get guild => text().nullable()();
  TextColumn get guildAcronym => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get deletedLocally =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
