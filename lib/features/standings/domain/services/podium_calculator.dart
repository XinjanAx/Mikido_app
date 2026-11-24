import '../../../../core/constants/app_constants.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../entities/standing_entity.dart';

/// Un lugar del podio. En eliminación sin partido por el 3er puesto puede
/// haber dos terceros (los dos perdedores de semifinal).
class PodiumEntry {
  final int place; // 1, 2 o 3
  final String playerId;
  final String name;

  const PodiumEntry({
    required this.place,
    required this.playerId,
    required this.name,
  });
}

/// Calcula el podio (1°, 2° y 3°) de una categoría — lógica pura.
///
/// - **Eliminación**: 1° el ganador de la Final, 2° el perdedor de la Final,
///   3° el ganador del partido por el 3er puesto. Si no hubo ese partido
///   (p. ej. con 3 competidores, la semifinal con BYE), 3° es quien perdió
///   en semifinal.
/// - **Liga / Grupos**: los tres primeros de la tabla de posiciones, que ya
///   viene ordenada por puntos, diferencia y desempate manual (el mismo
///   criterio que usa el banner "Campeón" de Encuentros).
class PodiumCalculator {
  PodiumCalculator._();

  static List<PodiumEntry> compute({
    required String mode,
    required List<MatchEntity> matches,
    required List<StandingEntity> standings,
  }) {
    if (mode == AppConstants.tournamentModeElimination) {
      return _elimination(matches);
    }
    return [
      for (var i = 0; i < standings.length && i < 3; i++)
        PodiumEntry(
          place: i + 1,
          playerId: standings[i].playerId,
          name: standings[i].playerName,
        ),
    ];
  }

  static List<PodiumEntry> _elimination(List<MatchEntity> matches) {
    MatchEntity? finalMatch;
    MatchEntity? thirdMatch;
    for (final m in matches) {
      if (m.round == 'Final') finalMatch = m;
      if (m.round == 'Tercer puesto') thirdMatch = m;
    }
    if (finalMatch == null || finalMatch.winner == null) return const [];

    final result = <PodiumEntry>[
      _winner(1, finalMatch),
      _loser(2, finalMatch),
    ];

    if (thirdMatch != null) {
      if (thirdMatch.winner != null) result.add(_winner(3, thirdMatch));
    } else {
      for (final m in matches) {
        if (m.round != 'Semifinal' || m.isBye || m.winner == null) continue;
        result.add(_loser(3, m));
      }
    }
    return result;
  }

  static PodiumEntry _winner(int place, MatchEntity m) {
    final home = m.winner == m.homePlayerId;
    return PodiumEntry(
      place: place,
      playerId: home ? m.homePlayerId : m.awayPlayerId,
      name: home ? m.homePlayerName : m.awayPlayerName,
    );
  }

  static PodiumEntry _loser(int place, MatchEntity m) {
    final home = m.winner == m.homePlayerId;
    return PodiumEntry(
      place: place,
      playerId: home ? m.awayPlayerId : m.homePlayerId,
      name: home ? m.awayPlayerName : m.homePlayerName,
    );
  }
}
