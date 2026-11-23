import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../standings/data/services/standings_recalculation_service.dart';
import '../datasources/fixture_local_datasource.dart';
import '../models/match_model.dart';

/// Aplica el resultado de un partido: guarda el marcador y recalcula la
/// tabla de posiciones.
///
/// Antes esto vivía duplicado (y de forma inconsistente) en dos lugares:
/// el datasource de Fixtures avanzaba el bracket pero no recalculaba
/// posiciones correctamente para todos los modos, y el de Results
/// recalculaba posiciones pero nunca avanzaba el bracket. Ahora ambos
/// caminos (editar resultado rápido desde Fixtures, o el formulario
/// dedicado de Results) pasan por aquí y quedan consistentes.
///
/// El avance de ronda en modo eliminación YA NO ocurre aquí de forma
/// automática: la UI (fixture_screen.dart / result_entry_screen.dart)
/// llama a `EliminationBracketService.checkRoundComplete` después de
/// guardar y le pide confirmación al admin (con la lista de jugadores que
/// pasan) antes de generar la siguiente ronda — así puede corregir un
/// marcador mal cargado sin que ya se haya generado la ronda siguiente.
class MatchResultService {
  final FixtureLocalDataSource _matches;
  final StandingsRecalculationService _standingsRecalc;
  final AppDatabase _db;

  const MatchResultService(
    this._matches,
    this._standingsRecalc,
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
      mesaOrder: existing.mesaOrder,
    );

    await _matches.upsert(updated, dirty: true);
    await _db.enqueueUpsert(
        SupabaseConstants.matchesTable, updated.id, updated.toJson());

    try {
      await _standingsRecalc.recalculate(updated.tournamentId);
    } catch (_) {
      // No interrumpir el guardado del resultado si falla el recálculo
    }

    return updated;
  }
}
