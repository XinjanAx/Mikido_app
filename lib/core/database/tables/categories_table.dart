import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get tournamentId => text()();
  TextColumn get description => text().nullable()();
  IntColumn get minAge => integer().nullable()();
  IntColumn get maxAge => integer().nullable()();
  IntColumn get maxParticipants => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get deletedLocally =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
