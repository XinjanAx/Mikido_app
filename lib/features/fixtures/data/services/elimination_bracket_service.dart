import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../datasources/fixture_local_datasource.dart';
import '../models/match_model.dart';

/// Ronda de eliminación ya terminada, con la siguiente ronda calculada
/// (nombre + ganadores que pasan) pero TODAVÍA sin generar en la base —
/// pensado para mostrarle esto al admin y pedirle que confirme antes de
/// llamar a [EliminationBracketService.generateNextRound].
class PendingRoundAdvance {
  final String tournamentId;
  final String completedRound;
  final String nextRound;
  final List<({String id, String name})> winners;

  /// Los dos perdedores de Semifinal, solo cuando [completedRound] es
  /// exactamente eso y hubo dos partidos de semifinal (el caso estándar de
  /// 4 semifinalistas) — se usan para generar el partido por el 3er
  /// puesto junto con la Final. `null` en cualquier otra ronda.
  final List<({String id, String name})>? thirdPlacePlayers;

  const PendingRoundAdvance({
    required this.tournamentId,
    required this.completedRound,
    required this.nextRound,
    required this.winners,
    this.thirdPlacePlayers,
  });
}

/// Verifica si todos los partidos de una ronda de eliminación están
/// finalizados y, si es así, genera automáticamente la siguiente ronda con
/// los ganadores. Opera 100% sobre la base local.
class EliminationBracketService {
  final FixtureLocalDataSource _local;
  final AppDatabase _db;

  const EliminationBracketService(this._local, this._db);

  /// Solo consulta si la ronda ya está lista para avanzar — no escribe
  /// nada. La UI usa esto para pedir confirmación antes de llamar a
  /// [generateNextRound].
  Future<PendingRoundAdvance?> checkRoundComplete({
    required String tournamentId,
    required String completedRound,
  }) async {
    // 1. Partidos de la ronda que se acaba de completar
    final roundMatches =
        await _local.getMatchesByRound(tournamentId, completedRound);
    if (roundMatches.isEmpty) return null;

    // 2. Verificar que TODOS estén finalizados
    final allFinished = roundMatches.every((m) => m.isFinished);
    if (!allFinished) return null; // aún faltan resultados

    // 2b. Ningún partido puede haber quedado empatado: en eliminación
    // directa cada uno necesita un ganador real para poder avanzar. Esto
    // ya se bloquea al guardar el resultado (fixture_screen.dart), pero
    // este método no debe asumirlo — si de todos modos llegara un empate
    // (dato viejo, u otro camino de guardado), antes se resolvía en
    // silencio a favor del local (`homeScore! >= awayScore!`), avanzando a
    // alguien sin que el marcador lo respaldara. Ahora se bloquea el
    // avance por completo hasta que el admin corrija el marcador.
    final hasUnresolvedTie = roundMatches.any((m) =>
        m.homeScore != null &&
        m.awayScore != null &&
        m.homeScore == m.awayScore);
    if (hasUnresolvedTie) return null;

    // 3. Obtener ganadores
    final winners = roundMatches.where((m) {
      return m.homeScore != null && m.awayScore != null;
    }).map((m) {
      if (m.homeScore! > m.awayScore!) {
        return (id: m.homePlayerId, name: m.homePlayerName);
      } else {
        return (id: m.awayPlayerId, name: m.awayPlayerName);
      }
    }).toList();

    // 4. Si solo queda 1 ganador, el torneo terminó
    if (winners.length <= 1) return null;

    // 5. Nombre de la siguiente ronda
    final nextRound = _nextRoundName(completedRound, winners.length);

    // 6. Verificar que la siguiente ronda no exista ya (idempotencia)
    final existingNext =
        await _local.getMatchesByRound(tournamentId, nextRound);
    if (existingNext.isNotEmpty) return null;

    // 7. Si la ronda que se completó es la Semifinal "estándar" (2
    // partidos, 4 semifinalistas), los dos perdedores juegan el partido
    // por el 3er puesto — se genera junto con la Final, no aparte, para
    // que el admin lo vea desde el inicio de esa fase.
    List<({String id, String name})>? thirdPlacePlayers;
    if (completedRound == 'Semifinal' && roundMatches.length == 2) {
      thirdPlacePlayers = roundMatches.map((m) {
        if (m.homeScore! > m.awayScore!) {
          return (id: m.awayPlayerId, name: m.awayPlayerName);
        } else {
          return (id: m.homePlayerId, name: m.homePlayerName);
        }
      }).toList();
    }

    return PendingRoundAdvance(
      tournamentId: tournamentId,
      completedRound: completedRound,
      nextRound: nextRound,
      winners: winners,
      thirdPlacePlayers: thirdPlacePlayers,
    );
  }

  /// Genera los partidos de la siguiente ronda a partir de un
  /// [PendingRoundAdvance] ya confirmado por el admin (ver
  /// [checkRoundComplete]).
  Future<void> generateNextRound(PendingRoundAdvance pending) async {
    final tournamentId = pending.tournamentId;
    final nextRound = pending.nextRound;
    final winners = pending.winners;

    // El número sigue la numeración de todo el torneo (no solo de la
    // ronda que se completó), para no repetir números ya usados en rondas
    // anteriores y mantener el orden correcto en la lista de partidos.
    final tournamentMatches =
        await _local.getMatchesByTournament(tournamentId);
    int matchNumber = tournamentMatches.fold<int>(
            0, (max, m) => (m.matchNumber ?? 0) > max ? m.matchNumber! : max) +
        1;
    final newMatches = <MatchModel>[];

    for (int i = 0; i < winners.length - 1; i += 2) {
      newMatches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        homePlayerId: winners[i].id,
        awayPlayerId: winners[i + 1].id,
        homePlayerName: winners[i].name,
        awayPlayerName: winners[i + 1].name,
        status: AppConstants.matchStatusPending,
        round: nextRound,
        matchNumber: matchNumber++,
      ));
    }

    // Si número impar de ganadores, el último pasa automáticamente (bye)
    if (winners.length.isOdd) {
      final lastWinner = winners.last;
      newMatches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        homePlayerId: lastWinner.id,
        awayPlayerId: lastWinner.id, // mismo jugador = bye
        homePlayerName: lastWinner.name,
        awayPlayerName: 'BYE',
        homeScore: 1,
        awayScore: 0,
        status: AppConstants.matchStatusFinished,
        round: nextRound,
        matchNumber: matchNumber++,
      ));
    }

    // Partido por el 3er puesto, entre los dos perdedores de semifinal —
    // se genera junto con la Final (ver checkRoundComplete paso 7), no
    // depende de que la Final se juegue primero.
    final thirdPlace = pending.thirdPlacePlayers;
    if (thirdPlace != null && thirdPlace.length == 2) {
      newMatches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        homePlayerId: thirdPlace[0].id,
        awayPlayerId: thirdPlace[1].id,
        homePlayerName: thirdPlace[0].name,
        awayPlayerName: thirdPlace[1].name,
        status: AppConstants.matchStatusPending,
        round: 'Tercer puesto',
        matchNumber: matchNumber++,
      ));
    }

    for (final m in newMatches) {
      await _local.upsert(m, dirty: true);
      await _db.enqueueUpsert(SupabaseConstants.matchesTable, m.id, m.toJson());
    }
  }

  /// Comprueba y genera en un solo paso, sin pedir confirmación — pensado
  /// para la sincronización en segundo plano (ver fixture_sync_adapter.dart),
  /// donde no hay nadie frente a la pantalla para confirmar (p. ej. cuando
  /// dos admins en dispositivos distintos completan la misma ronda entre
  /// los dos). La UI interactiva usa [checkRoundComplete] +
  /// [generateNextRound] por separado para poder mostrar el diálogo de
  /// confirmación en el medio.
  Future<void> advance({
    required String tournamentId,
    required String completedRound,
  }) async {
    final pending = await checkRoundComplete(
      tournamentId: tournamentId,
      completedRound: completedRound,
    );
    if (pending == null) return;
    await generateNextRound(pending);
  }

  /// Nombres de ronda en orden — deben coincidir con los que usa
  /// fixture_generator.dart (_eliminationRoundName) para la ronda inicial.
  /// Público para que la UI pueda saber si una ronda ya tiene la
  /// siguiente generada (y por lo tanto debe bloquear su edición).
  static const roundOrder = [
    'Sesentaicuatroavos de final',
    'Treintaidosavos de final',
    'Dieciseisavos de final',
    'Octavos de final',
    'Cuartos de final',
    'Semifinal',
    'Final',
  ];

  /// Avanza al SIGUIENTE nombre de la secuencia a partir de la ronda que
  /// se acaba de completar, en vez de re-derivarlo solo del número de
  /// ganadores. Con conteos que no son potencia de 2 (p. ej. 12
  /// jugadores → 6 partidos de "Cuartos de final" → 6 ganadores),
  /// derivarlo solo del conteo podía devolver el MISMO nombre de la
  /// ronda que se acaba de completar (6 caía otra vez en "Cuartos de
  /// final"), lo que hacía que el chequeo de idempotencia de más arriba
  /// (`existingNext.isNotEmpty`) encontrara la ronda ya completada y
  /// creyera que la siguiente ya existía — dejando el cuadro
  /// congelado ahí para siempre sin generar nada más.
  String _nextRoundName(String completedRound, int winners) {
    final idx = roundOrder.indexOf(completedRound);
    if (idx != -1 && idx < roundOrder.length - 1) {
      return roundOrder[idx + 1];
    }
    // Ronda no reconocida (no debería pasar): usar el conteo como respaldo.
    if (winners > 64) return 'Sesentaicuatroavos de final';
    if (winners > 32) return 'Treintaidosavos de final';
    if (winners > 16) return 'Dieciseisavos de final';
    if (winners > 8) return 'Octavos de final';
    if (winners > 4) return 'Cuartos de final';
    if (winners > 2) return 'Semifinal';
    return 'Final';
  }
}
