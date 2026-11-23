import 'package:drift/drift.dart';

@DataClassName('MatchRow')
class Matches extends Table {
  TextColumn get id => text()();
  TextColumn get tournamentId => text()();
  TextColumn get homePlayerId => text()();
  TextColumn get awayPlayerId => text()();
  TextColumn get homePlayerName => text()();
  TextColumn get awayPlayerName => text()();
  IntColumn get homeScore => integer().nullable()();
  IntColumn get awayScore => integer().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  TextColumn get round => text().nullable()();
  IntColumn get matchNumber => integer().nullable()();

  /// Turno global del encuentro dentro de su mesa (1, 2, 3...), mezclando
  /// todas las categorías de la mesa. Lo asigna MesaScheduleService, nunca
  /// el usuario. null = sin turno (los BYE, o datos anteriores a la v6).
  IntColumn get mesaOrder => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  BoolColumn get deletedLocally =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
