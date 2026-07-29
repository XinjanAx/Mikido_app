import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../standings/data/services/standings_recalculation_service.dart';
import '../../../tournaments/data/datasources/tournament_local_datasource.dart';
import '../datasources/fixture_local_datasource.dart';
import '../models/match_model.dart';
import 'elimination_bracket_service.dart';

/// Aplica el resultado de un partido: guarda el marcador, recalcula la
/// tabla de posiciones y avanza el bracket si el torneo es de eliminación.
///
/// Antes esto vivía duplicado (y de forma inconsistente) en dos lugares:
/// el datasource de Fixtures avanzaba el bracket pero no recalculaba
/// posiciones correctamente para todos los modos, y el de Results
/// recalculaba posiciones pero nunca avanzaba el bracket. Ahora ambos
/// caminos (editar resultado rápido desde Fixtures, o el formulario
/// dedicado de Results) pasan por aquí y quedan consistentes.
class MatchResultService {
  final FixtureLocalDataSource _matches;
  final TournamentLocalDataSource _tournaments;
  final StandingsRecalculationService _standingsRecalc;
  final EliminationBracketService _bracket;
  final AppDatabase _db;

  const MatchResultService(
    this._matches,
    this._tournaments,
    this._standingsRecalc,
    this._bracket,
    this._db,
  );

  Future<MatchModel> applyResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    final existing = await _matches.getMatchById(matchId);
    if (existing == null) {
      throw StateError('Partido no encontrado: $matchId');
    }

    final updated = MatchModel(
      id: existing.id,
      tournamentId: existing.tournamentId,
      homePlayerId: existing.homePlayerId,
      awayPlayerId: existing.awayPlayerId,
      homePlayerName: existing.homePlayerName,
      awayPlayerName: existing.awayPlayerName,
      homeScore: homeScore,
      awayScore: awayScore,
      status: AppConstants.matchStatusFinished,
      scheduledAt: existing.scheduledAt,
      round: existing.round,
      matchNumber: existing.matchNumber,
      createdAt: existing.createdAt,
    );

    await _matches.upsert(updated, dirty: true);
    await _db.enqueueUpsert(
        SupabaseConstants.matchesTable, updated.id, updated.toJson());

    try {
      await _standingsRecalc.recalculate(updated.tournamentId);
    } catch (e) {
      // No interrumpir el guardado del resultado si falla el recálculo
      // ignore: avoid_print
      print('STANDINGS: error al recalcular: $e');
    }

    try {
      final tournament = await _tournaments.getTournamentById(updated.tournamentId);
      if (tournament?.mode == AppConstants.tournamentModeElimination) {
        await _bracket.advance(
          tournamentId: updated.tournamentId,
          completedRound: updated.round ?? '',
        );
      }
    } catch (_) {
      // No interrumpir si falla el avance del bracket
    }

    return updated;
  }
}
