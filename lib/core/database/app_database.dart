import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'database_location.dart';
import 'tables/enrollments_table.dart';
import 'tables/matches_table.dart';
import 'tables/mesas_table.dart';
import 'tables/players_table.dart';
import 'tables/results_table.dart';
import 'tables/standings_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/tournaments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Mesas,
  Tournaments,
  Players,
  Enrollments,
  Matches,
  Results,
  Standings,
  SyncQueueEntries,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // v1: solo tournaments + sync_queue_entries.
          if (from < 2) {
            // v2: categories, players, enrollments.
            await m.createTable(players);
            await m.createTable(enrollments);
          }
          if (from < 3) {
            // v3: matches, results, standings.
            await m.createTable(matches);
            await m.createTable(results);
            await m.createTable(standings);
          }
          if (from < 4) {
            // v4: se elimina el concepto de categoría por completo.
            await m.deleteTable('categories');
            await m.alterTable(TableMigration(matches));
            await m.alterTable(TableMigration(standings));
            await m.alterTable(TableMigration(enrollments));
          }
          if (from < 5) {
            // v5: columna manualRank en standings, para el desempate
            // manual al finalizar el torneo. `newColumns` es obligatorio
            // acá: sin avisarle a Drift que es una columna nueva, intenta
            // copiarla también desde la tabla vieja (que todavía no la
            // tiene) y la migración falla con "no such column: manual_rank".
            await m.alterTable(TableMigration(
              standings,
              newColumns: [standings.manualRank],
            ));
          }
          if (from < 6) {
            // v6: mesas. Cada categoría (tabla tournaments) pertenece a una
            // mesa y cada encuentro tiene su turno global dentro de ella.
            // Columnas nullable: los datos viejos se completan con el pull
            // desde Supabase (la migración SQL los asigna a "Mesa 1").
            await m.createTable(mesas); // CREATE TABLE IF NOT EXISTS
            await _addColumnIfMissing(m, tournaments, tournaments.mesaId);
            await _addColumnIfMissing(m, matches, matches.mesaOrder);
          }
          if (from < 7) {
            // v7: color de cada categoría.
            await _addColumnIfMissing(m, tournaments, tournaments.color);
          }
          if (from < 8) {
            // v8: gremio/clan del participante y su acrónimo.
            await _addColumnIfMissing(m, players, players.guild);
            await _addColumnIfMissing(m, players, players.guildAcronym);
          }
        },
      );

  /// Agrega la columna solo si todavía no existe.
  ///
  /// Necesario porque una versión ANTERIOR de la app puede abrir esta misma
  /// base (en Windows todas usan Documents\torneo_app.sqlite): al ver una
  /// base "más nueva" que la suya, Drift le baja la marca de versión
  /// (user_version) sin tocar las tablas. Cuando después vuelve a abrirla
  /// esta versión, cree que falta migrar e intentaba agregar columnas que ya
  /// estaban → "duplicate column name". Visto en la práctica con la v7
  /// (`color`) tras abrir el build 2.0.1 (v6).
  Future<void> _addColumnIfMissing(
      Migrator m, TableInfo table, GeneratedColumn column) async {
    final existing = await customSelect(
            'PRAGMA table_info("${table.actualTableName}")')
        .get();
    final exists = existing.any((r) => r.read<String>('name') == column.name);
    if (!exists) await m.addColumn(table, column);
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      // Fuera de OneDrive/iCloud en escritorio (ver DatabaseLocation).
      final file = await DatabaseLocation.resolve();
      return NativeDatabase.createInBackground(file);
    });
  }

  // ---------- Mesas ----------

  Future<List<Mesa>> getAllMesas() {
    return (select(mesas)
          ..where((t) => t.deletedLocally.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Stream<List<Mesa>> watchAllMesas() {
    return (select(mesas)
          ..where((t) => t.deletedLocally.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<Mesa?> getMesaById(String id) {
    return (select(mesas)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertMesa(MesasCompanion entry) {
    return into(mesas).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteMesa(String id) {
    return (update(mesas)..where((t) => t.id.equals(id))).write(
      const MesasCompanion(deletedLocally: Value(true), dirty: Value(true)),
    );
  }

  /// Deshace un borrado local que el servidor rechazó.
  Future<void> restoreMesa(String id) {
    return (update(mesas)..where((t) => t.id.equals(id))).write(
      const MesasCompanion(deletedLocally: Value(false), dirty: Value(false)),
    );
  }

  Future<void> hardDeleteMesa(String id) {
    return (delete(mesas)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearMesaDirty(String id) {
    return (update(mesas)..where((t) => t.id.equals(id)))
        .write(const MesasCompanion(dirty: Value(false)));
  }

  /// Categorías (tabla tournaments) de una mesa.
  Future<List<Tournament>> getTournamentsByMesa(String mesaId) {
    return (select(tournaments)
          ..where((t) =>
              t.mesaId.equals(mesaId) & t.deletedLocally.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Todos los encuentros vivos de todas las categorías de una mesa.
  Future<List<MatchRow>> getMatchesByMesa(String mesaId) {
    final query = select(matches).join([
      innerJoin(tournaments, tournaments.id.equalsExp(matches.tournamentId)),
    ])
      ..where(tournaments.mesaId.equals(mesaId) &
          tournaments.deletedLocally.equals(false) &
          matches.deletedLocally.equals(false));
    return query.map((row) => row.readTable(matches)).get();
  }

  /// Versión reactiva de [getMatchesByMesa], para la pantalla de la cola.
  Stream<List<MatchRow>> watchMatchesByMesa(String mesaId) {
    final query = select(matches).join([
      innerJoin(tournaments, tournaments.id.equalsExp(matches.tournamentId)),
    ])
      ..where(tournaments.mesaId.equals(mesaId) &
          tournaments.deletedLocally.equals(false) &
          matches.deletedLocally.equals(false))
      ..orderBy([OrderingTerm.asc(matches.mesaOrder)]);
    return query.map((row) => row.readTable(matches)).watch();
  }

  // ---------- Tournaments ----------

  Future<List<Tournament>> getAllTournaments() {
    return (select(tournaments)
          ..where((t) => t.deletedLocally.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<Tournament>> watchAllTournaments() {
    return (select(tournaments)
          ..where((t) => t.deletedLocally.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<Tournament?> getTournamentById(String id) {
    return (select(tournaments)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> upsertTournament(TournamentsCompanion entry) {
    return into(tournaments).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteTournament(String id) {
    return (update(tournaments)..where((t) => t.id.equals(id))).write(
      const TournamentsCompanion(
        deletedLocally: Value(true),
        dirty: Value(true),
      ),
    );
  }

  Future<void> hardDeleteTournament(String id) {
    return (delete(tournaments)..where((t) => t.id.equals(id))).go();
  }

  Future<void> clearTournamentDirty(String id) {
    return (update(tournaments)..where((t) => t.id.equals(id)))
        .write(const TournamentsCompanion(dirty: Value(false)));
  }

  // ---------- Players ----------

  Future<List<Player>> getAllPlayersLocal() {
    return (select(players)
          ..where((p) => p.deletedLocally.equals(false))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  Stream<List<Player>> watchAllPlayersLocal() {
    return (select(players)
          ..where((p) => p.deletedLocally.equals(false))
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  Future<Player?> getPlayerById(String id) {
    return (select(players)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertPlayer(PlayersCompanion entry) {
    return into(players).insertOnConflictUpdate(entry);
  }

  Future<void> softDeletePlayer(String id) {
    return (update(players)..where((p) => p.id.equals(id))).write(
      const PlayersCompanion(deletedLocally: Value(true), dirty: Value(true)),
    );
  }

  Future<void> hardDeletePlayer(String id) {
    return (delete(players)..where((p) => p.id.equals(id))).go();
  }

  Future<void> clearPlayerDirty(String id) {
    return (update(players)..where((p) => p.id.equals(id)))
        .write(const PlayersCompanion(dirty: Value(false)));
  }

  // ---------- Enrollments ----------

  /// Jugadores inscritos en un torneo, resuelto con un join local
  Future<List<(Player, Enrollment)>> getPlayersWithEnrollmentByTournament(
      String tournamentId) async {
    final query = select(players).join([
      innerJoin(enrollments, enrollments.playerId.equalsExp(players.id)),
    ])
      ..where(enrollments.tournamentId.equals(tournamentId) &
          enrollments.deletedLocally.equals(false) &
          players.deletedLocally.equals(false));
    final rows = await query.get();
    return rows
        .map((row) => (row.readTable(players), row.readTable(enrollments)))
        .toList();
  }

  Future<Enrollment?> getEnrollmentById(String id) {
    return (select(enrollments)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Enrollment>> getAllEnrollmentsLocal() {
    return (select(enrollments)..where((e) => e.deletedLocally.equals(false)))
        .get();
  }

  Future<void> upsertEnrollment(EnrollmentsCompanion entry) {
    return into(enrollments).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteEnrollment(String id) {
    return (update(enrollments)..where((e) => e.id.equals(id))).write(
      const EnrollmentsCompanion(
          deletedLocally: Value(true), dirty: Value(true)),
    );
  }

  Future<void> hardDeleteEnrollment(String id) {
    return (delete(enrollments)..where((e) => e.id.equals(id))).go();
  }

  Future<void> clearEnrollmentDirty(String id) {
    return (update(enrollments)..where((e) => e.id.equals(id)))
        .write(const EnrollmentsCompanion(dirty: Value(false)));
  }

  // ---------- Matches ----------

  Future<List<MatchRow>> getMatchesByTournament(String tournamentId) {
    return (select(matches)
          ..where((m) =>
              m.tournamentId.equals(tournamentId) &
              m.deletedLocally.equals(false))
          ..orderBy([(m) => OrderingTerm.asc(m.matchNumber)]))
        .get();
  }

  Stream<List<MatchRow>> watchMatches(String tournamentId) {
    return (select(matches)
          ..where((m) =>
              m.tournamentId.equals(tournamentId) &
              m.deletedLocally.equals(false))
          ..orderBy([(m) => OrderingTerm.asc(m.matchNumber)]))
        .watch();
  }

  Future<MatchRow?> getMatchById(String id) {
    return (select(matches)..where((m) => m.id.equals(id))).getSingleOrNull();
  }

  Future<List<MatchRow>> getMatchesByRound(String tournamentId, String round) {
    return (select(matches)
          ..where((m) =>
              m.tournamentId.equals(tournamentId) &
              m.round.equals(round) &
              m.deletedLocally.equals(false)))
        .get();
  }

  Future<List<MatchRow>> getAllMatchesLocal() {
    return (select(matches)..where((m) => m.deletedLocally.equals(false)))
        .get();
  }

  Future<void> upsertMatch(MatchesCompanion entry) {
    return into(matches).insertOnConflictUpdate(entry);
  }

  Future<void> softDeleteMatch(String id) {
    return (update(matches)..where((m) => m.id.equals(id))).write(
      const MatchesCompanion(deletedLocally: Value(true), dirty: Value(true)),
    );
  }

  Future<void> hardDeleteMatch(String id) {
    return (delete(matches)..where((m) => m.id.equals(id))).go();
  }

  Future<void> clearMatchDirty(String id) {
    return (update(matches)..where((m) => m.id.equals(id)))
        .write(const MatchesCompanion(dirty: Value(false)));
  }

  // ---------- Results ----------

  Future<List<Result>> getResultsByTournament(String tournamentId) {
    return (select(results)
          ..where((r) => r.tournamentId.equals(tournamentId))
          ..orderBy([(r) => OrderingTerm.desc(r.registeredAt)]))
        .get();
  }

  Future<Result?> getResultByMatch(String matchId) {
    return (select(results)..where((r) => r.matchId.equals(matchId)))
        .getSingleOrNull();
  }

  Future<Result?> getResultById(String id) {
    return (select(results)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  Future<List<Result>> getAllResultsLocal() => select(results).get();

  Future<void> upsertResult(ResultsCompanion entry) {
    return into(results).insertOnConflictUpdate(entry);
  }

  Future<void> clearResultDirty(String id) {
    return (update(results)..where((r) => r.id.equals(id)))
        .write(const ResultsCompanion(dirty: Value(false)));
  }

  // ---------- Standings ----------

  // Desempate: puntos de torneo primero, luego la diferencia de puntos
  // anotados en cancha (favor - contra), y por último manualRank — el
  // orden que el admin eligió a mano para los que seguían empatados
  // incluso en diferencia (ver TiebreakDetector /
  // showTiebreakResolutionDialog). Sin manualRank, un empate ahí quedaba
  // en el orden que la fila tuviera en SQLite, no en un criterio real.
  Future<List<Standing>> getStandingsByTournament(String tournamentId) {
    return (select(standings)
          ..where((s) => s.tournamentId.equals(tournamentId))
          ..orderBy([
            (s) => OrderingTerm.desc(s.points),
            (s) => OrderingTerm.desc(s.goalsFor - s.goalsAgainst),
            (s) => OrderingTerm.asc(s.manualRank),
          ]))
        .get();
  }

  Stream<List<Standing>> watchStandings(String tournamentId) {
    return (select(standings)
          ..where((s) => s.tournamentId.equals(tournamentId))
          ..orderBy([
            (s) => OrderingTerm.desc(s.points),
            (s) => OrderingTerm.desc(s.goalsFor - s.goalsAgainst),
            (s) => OrderingTerm.asc(s.manualRank),
          ]))
        .watch();
  }

  Future<Standing?> getStandingById(String id) {
    return (select(standings)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<Standing>> getAllStandingsLocal() => select(standings).get();

  Future<void> upsertStanding(StandingsCompanion entry) {
    return into(standings).insertOnConflictUpdate(entry);
  }

  Future<void> clearStandingDirty(String id) {
    return (update(standings)..where((s) => s.id.equals(id)))
        .write(const StandingsCompanion(dirty: Value(false)));
  }

  // ---------- Cola de sincronización (outbox) ----------

  /// Atajo: encola un upsert con el payload ya serializado a JSON.
  Future<void> enqueueUpsert(
      String table, String rowId, Map<String, dynamic> payload) {
    return enqueueSyncOp(SyncQueueEntriesCompanion.insert(
      id: const Uuid().v4(),
      entityTable: table,
      rowId: rowId,
      operation: 'upsert',
      payload: Value(jsonEncode(payload)),
    ));
  }

  /// Atajo: encola un borrado.
  Future<void> enqueueDelete(String table, String rowId) {
    return enqueueSyncOp(SyncQueueEntriesCompanion.insert(
      id: const Uuid().v4(),
      entityTable: table,
      rowId: rowId,
      operation: 'delete',
    ));
  }

  Future<void> enqueueSyncOp(SyncQueueEntriesCompanion entry) {
    return into(syncQueueEntries).insert(entry);
  }

  Future<List<SyncQueueEntry>> pendingSyncOps() {
    return (select(syncQueueEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> removeSyncOp(String id) {
    return (delete(syncQueueEntries)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markSyncOpFailed(String id, int retryCount, String error) {
    return (update(syncQueueEntries)..where((t) => t.id.equals(id))).write(
      SyncQueueEntriesCompanion(
        retryCount: Value(retryCount),
        lastError: Value(error),
      ),
    );
  }
}
