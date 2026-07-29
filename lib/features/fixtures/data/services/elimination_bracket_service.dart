import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../datasources/fixture_local_datasource.dart';
import '../models/match_model.dart';

/// Verifica si todos los partidos de una ronda de eliminación están
/// finalizados y, si es así, genera automáticamente la siguiente ronda con
/// los ganadores. Opera 100% sobre la base local.
class EliminationBracketService {
  final FixtureLocalDataSource _local;
  final AppDatabase _db;

  const EliminationBracketService(this._local, this._db);

  Future<void> advance({
    required String tournamentId,
    required String completedRound,
  }) async {
    // 1. Partidos de la ronda que se acaba de completar
    final roundMatches =
        await _local.getMatchesByRound(tournamentId, completedRound);

    // 2. Verificar que TODOS estén finalizados
    final allFinished = roundMatches.every((m) => m.isFinished);
    if (!allFinished) return; // aún faltan resultados

    // 3. Obtener ganadores
    final winners = roundMatches.where((m) {
      return m.homeScore != null && m.awayScore != null;
    }).map((m) {
      if (m.homeScore! >= m.awayScore!) {
        return (id: m.homePlayerId, name: m.homePlayerName);
      } else {
        return (id: m.awayPlayerId, name: m.awayPlayerName);
      }
    }).toList();

    // 4. Si solo queda 1 ganador, el torneo terminó
    if (winners.length <= 1) return;

    // 5. Nombre de la siguiente ronda
    final nextRound = _nextRoundName(winners.length);

    // 6. Verificar que la siguiente ronda no exista ya (idempotencia)
    final existingNext =
        await _local.getMatchesByRound(tournamentId, nextRound);
    if (existingNext.isNotEmpty) return;

    // 7. Generar partidos de la siguiente ronda.
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

    for (final m in newMatches) {
      await _local.upsert(m, dirty: true);
      await _db.enqueueUpsert(SupabaseConstants.matchesTable, m.id, m.toJson());
    }
  }

  String _nextRoundName(int winners) {
    if (winners > 8) return 'Octavos de final';
    if (winners > 4) return 'Cuartos de final';
    if (winners > 2) return 'Semifinal';
    if (winners == 2) return 'Final';
    return 'Campeón';
  }
}
