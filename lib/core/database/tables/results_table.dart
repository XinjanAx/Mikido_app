import 'package:drift/drift.dart';

class Results extends Table {
  TextColumn get id => text()();
  TextColumn get matchId => text()();
  TextColumn get tournamentId => text()();
  TextColumn get homePlayerId => text()();
  TextColumn get awayPlayerId => text()();
  IntColumn get homeScore => integer()();
  IntColumn get awayScore => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get registeredBy => text()();
  DateTimeColumn get registeredAt => dateTime()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
