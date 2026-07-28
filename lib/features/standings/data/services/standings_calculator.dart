import '../../../../core/constants/app_constants.dart';
import '../../../fixtures/domain/entities/match_entity.dart';

class PlayerStat {
  final String playerId;
  final String playerName;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;

  PlayerStat(this.playerId, this.playerName);
}

/// Cálculo puro de la tabla de posiciones a partir de partidos finalizados.
/// No toca ninguna base de datos.
class StandingsCalculator {
  StandingsCalculator._();

  static List<PlayerStat> compute(List<MatchEntity> finishedMatches) {
    final stats = <String, PlayerStat>{};
    PlayerStat statFor(String id, String name) =>
        stats.putIfAbsent(id, () => PlayerStat(id, name));

    for (final m in finishedMatches) {
      final homeScore = m.homeScore;
      final awayScore = m.awayScore;
      if (homeScore == null || awayScore == null) continue;
      // Los "bye" de eliminación enfrentan al mismo jugador consigo mismo:
      // no cuentan para la tabla de posiciones.
      if (m.homePlayerId == m.awayPlayerId) continue;

      final home = statFor(m.homePlayerId, m.homePlayerName);
      final away = statFor(m.awayPlayerId, m.awayPlayerName);

      home.played++;
      away.played++;
      home.goalsFor += homeScore;
      home.goalsAgainst += awayScore;
      away.goalsFor += awayScore;
      away.goalsAgainst += homeScore;

      if (homeScore > awayScore) {
        home.won++;
        home.points += AppConstants.pointsForWin;
        away.lost++;
        away.points += AppConstants.pointsForLoss;
      } else if (awayScore > homeScore) {
        away.won++;
        away.points += AppConstants.pointsForWin;
        home.lost++;
        home.points += AppConstants.pointsForLoss;
      } else {
        home.drawn++;
        away.drawn++;
        home.points += AppConstants.pointsForDraw;
        away.points += AppConstants.pointsForDraw;
      }
    }

    return stats.values.toList();
  }
}
