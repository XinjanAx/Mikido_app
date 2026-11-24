import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/constants/app_constants.dart';
import 'package:torneo_app/features/fixtures/domain/entities/match_entity.dart';
import 'package:torneo_app/features/mesas/domain/services/mesa_progress.dart';

int _id = 0;
MatchEntity _m(String t, String home, String away, {String? round}) =>
    MatchEntity(
      id: 'm${_id++}',
      tournamentId: t,
      homePlayerId: home,
      awayPlayerId: away,
      homePlayerName: home,
      awayPlayerName: away == home ? 'BYE' : away,
      status: AppConstants.matchStatusPending,
      round: round,
    );

void main() {
  String? modes(String id) => switch (id) {
        'elim' => AppConstants.tournamentModeElimination,
        'liga' => AppConstants.tournamentModeLeague,
        _ => null,
      };

  test('eliminación de 8 recién generada: 7 + 3er puesto = 8', () {
    final matches = [
      _m('elim', 'a', 'b'),
      _m('elim', 'c', 'd'),
      _m('elim', 'e', 'f'),
      _m('elim', 'g', 'h'),
    ];
    expect(MesaProgress.projectedTotal(matches, modes), 8);
  });

  test('eliminación de 5 (3 BYE en primera ronda): 4 + 3er puesto = 5', () {
    final matches = [
      _m('elim', 'a', 'b'),
      _m('elim', 'c', 'c'), // BYE
      _m('elim', 'd', 'd'), // BYE
      _m('elim', 'e', 'e'), // BYE
    ];
    expect(MesaProgress.projectedTotal(matches, modes), 5);
  });

  test('eliminación de 3: 2 encuentros, sin 3er puesto', () {
    final matches = [_m('elim', 'a', 'b'), _m('elim', 'c', 'c')];
    expect(MesaProgress.projectedTotal(matches, modes), 2);
  });

  test('liga cuenta sus encuentros tal cual y se suma a la eliminación', () {
    final matches = [
      _m('liga', 'x', 'y'),
      _m('liga', 'x', 'z'),
      _m('liga', 'y', 'z'),
      _m('elim', 'a', 'b'),
      _m('elim', 'c', 'd'),
    ];
    expect(MesaProgress.projectedTotal(matches, modes), 3 + 4);
  });

  test('el total no cambia al generar la siguiente ronda', () {
    final first = [
      _m('elim', 'a', 'b'),
      _m('elim', 'c', 'd'),
    ];
    final withFinal = [
      ...first,
      _m('elim', 'a', 'c', round: 'Final'),
      _m('elim', 'b', 'd', round: 'Tercer puesto'),
    ];
    expect(MesaProgress.projectedTotal(first, modes),
        MesaProgress.projectedTotal(withFinal, modes));
  });
}
