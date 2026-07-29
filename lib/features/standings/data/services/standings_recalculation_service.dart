import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../fixtures/data/datasources/fixture_local_datasource.dart';
import '../../data/models/standing_model.dart';
import '../datasources/standing_local_datasource.dart';
import 'standings_calculator.dart';

/// Recalcula la tabla de posiciones completa de un torneo a partir de los
/// partidos finalizados guardados localmente, y encola el resultado para
/// subirlo a Supabase. Usado tanto al registrar un resultado desde Fixtures
/// como desde el formulario de Results, para que ambos caminos queden
/// consistentes.
class StandingsRecalculationService {
  final FixtureLocalDataSource _matches;
  final StandingLocalDataSource _standings;
  final AppDatabase _db;

  const StandingsRecalculationService(this._matches, this._standings, this._db);

  Future<void> recalculate(String tournamentId) async {
    final allMatches = await _matches.getMatchesByTournament(tournamentId);
    final finished = allMatches.where((m) => m.isFinished).toList();
    if (finished.isEmpty) return;

    final existing = await _standings.getStandings(tournamentId);
    final existingIds = <String, String>{
      for (final s in existing) s.playerId: s.id,
    };

    final stats = StandingsCalculator.compute(finished);
    for (final s in stats) {
      final model = StandingModel(
        id: existingIds[s.playerId] ?? const Uuid().v4(),
        tournamentId: tournamentId,
        playerId: s.playerId,
        playerName: s.playerName,
        played: s.played,
        won: s.won,
        drawn: s.drawn,
        lost: s.lost,
        goalsFor: s.goalsFor,
        goalsAgainst: s.goalsAgainst,
        points: s.points,
      );
      await _standings.upsert(model, dirty: true);
      await _db.enqueueUpsert(
          SupabaseConstants.standingsTable, model.id, model.toJson());
    }
  }
}
