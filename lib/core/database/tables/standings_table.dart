import 'package:drift/drift.dart';

class Standings extends Table {
  TextColumn get id => text()();
  TextColumn get tournamentId => text()();
  TextColumn get categoryId => text()();
  TextColumn get playerId => text()();
  TextColumn get playerName => text()();
  IntColumn get played => integer().withDefault(const Constant(0))();
  IntColumn get won => integer().withDefault(const Constant(0))();
  IntColumn get drawn => integer().withDefault(const Constant(0))();
  IntColumn get lost => integer().withDefault(const Constant(0))();
  IntColumn get goalsFor => integer().withDefault(const Constant(0))();
  IntColumn get goalsAgainst => integer().withDefault(const Constant(0))();
  IntColumn get points => integer().withDefault(const Constant(0))();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
