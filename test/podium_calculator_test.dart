import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/constants/app_constants.dart';
import 'package:torneo_app/features/fixtures/domain/entities/match_entity.dart';
import 'package:torneo_app/features/standings/domain/entities/standing_entity.dart';
import 'package:torneo_app/features/standings/domain/services/podium_calculator.dart';

MatchEntity _m(String round, String home, String away, int hs, int as_) =>
    MatchEntity(
      id: '$round-$home-$away',
      tournamentId: 't',
      homePlayerId: home,
      awayPlayerId: away,
      homePlayerName: home,
      awayPlayerName: away,
      homeScore: hs,
      awayScore: as_,
      status: AppConstants.matchStatusFinished,
      round: round,
    );

StandingEntity _s(String name, int points) => StandingEntity(
      id: name,
      tournamentId: 't',
      playerId: name,
      playerName: name,
      played: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      goalsFor: 0,
      goalsAgainst: 0,
      points: points,
    );

List<String> _fmt(List<PodiumEntry> p) =>
    [for (final e in p) '${e.place}:${e.name}'];

void main() {
  test('eliminación con 3er puesto', () {
    final podium = PodiumCalculator.compute(
      mode: AppConstants.tournamentModeElimination,
      standings: const [],
      matches: [
        _m('Semifinal', 'Ana', 'Bea', 2, 0),
        _m('Semifinal', 'Caro', 'Dani', 1, 0),
        _m('Tercer puesto', 'Bea', 'Dani', 0, 3),
        _m('Final', 'Ana', 'Caro', 0, 2),
      ],
    );
    expect(_fmt(podium), ['1:Caro', '2:Ana', '3:Dani']);
  });

  test('eliminación de 3 (semifinal con BYE, sin 3er puesto)', () {
    final podium = PodiumCalculator.compute(
      mode: AppConstants.tournamentModeElimination,
      standings: const [],
      matches: [
        _m('Semifinal', 'Ana', 'Bea', 2, 1),
        _m('Semifinal', 'Caro', 'Caro', 0, 0), // BYE
        _m('Final', 'Ana', 'Caro', 3, 1),
      ],
    );
    expect(_fmt(podium), ['1:Ana', '2:Caro', '3:Bea']);
  });

  test('eliminación sin Final jugada → sin podio', () {
    final podium = PodiumCalculator.compute(
      mode: AppConstants.tournamentModeElimination,
      standings: const [],
      matches: [_m('Semifinal', 'Ana', 'Bea', 2, 1)],
    );
    expect(podium, isEmpty);
  });

  test('liga: los tres primeros de la tabla', () {
    final podium = PodiumCalculator.compute(
      mode: AppConstants.tournamentModeLeague,
      matches: const [],
      standings: [_s('Ana', 9), _s('Bea', 6), _s('Caro', 3), _s('Dani', 0)],
    );
    expect(_fmt(podium), ['1:Ana', '2:Bea', '3:Caro']);
  });
}
