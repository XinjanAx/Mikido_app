import 'package:drift/drift.dart';

class Standings extends Table {
  TextColumn get id => text()();
  TextColumn get tournamentId => text()();
  TextColumn get playerId => text()();
  TextColumn get playerName => text()();
  IntColumn get played => integer().withDefault(const Constant(0))();
  IntColumn get won => integer().withDefault(const Constant(0))();
  IntColumn get drawn => integer().withDefault(const Constant(0))();
  IntColumn get lost => integer().withDefault(const Constant(0))();
  IntColumn get goalsFor => integer().withDefault(const Constant(0))();
  IntColumn get goalsAgainst => integer().withDefault(const Constant(0))();
  IntColumn get points => integer().withDefault(const Constant(0))();

  // Desempate manual: solo se llena cuando el admin resuelve a mano un
  // empate en puntos + diferencia al finalizar el torneo (ver
  // TiebreakDetector). 0 = mejor ubicado dentro de su grupo de empatados.
  // Null para todos los demás — StandingsRecalculationService reconstruye
  // cada fila desde cero en cada resultado guardado, así que un desempate
  // manual queda "olvidado" solo apenas cambia algo que lo invalidaría.
  IntColumn get manualRank => integer().nullable()();

  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
