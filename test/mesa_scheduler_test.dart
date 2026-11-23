import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/constants/app_constants.dart';
import 'package:torneo_app/features/fixtures/data/services/fixture_generator.dart';
import 'package:torneo_app/features/mesas/domain/services/mesa_scheduler.dart';

ScheduleItem item(String id, String cat, String a, String b,
        {String? round, bool played = false}) =>
    ScheduleItem(
      id: id,
      tournamentId: cat,
      round: round ?? 'R',
      homePlayerId: a,
      awayPlayerId: b,
      isPlayed: played,
    );

/// Cantidad de pares de turnos consecutivos que comparten competidor.
int consecutiveConflicts(List<ScheduleItem> q) {
  var n = 0;
  for (var i = 1; i < q.length; i++) {
    if (q[i].sharesPlayerWith(q[i - 1])) n++;
  }
  return n;
}

List<ScheduleItem> leagueItems(String cat, List<String> players) {
  final matches = FixtureGenerator.generate(
    tournamentId: cat,
    mode: AppConstants.tournamentModeLeague,
    playerIds: players,
    playerNames: players,
  );
  return [
    for (final m in matches)
      item(m.id, cat, m.homePlayerId, m.awayPlayerId, round: m.round),
  ];
}

void main() {
  group('interleave (categoría nueva)', () {
    test('una liga sola en una mesa vacía: nadie combate dos seguidos', () {
      final league = leagueItems('A', ['a1', 'a2', 'a3', 'a4', 'a5', 'a6']);
      final q = MesaScheduler.interleave(queue: const [], newItems: league);
      expect(q.length, league.length);
      expect(consecutiveConflicts(q), 0);
    });

    test('dos categorías se intercalan parejas y sin choques', () {
      final a = leagueItems('A', ['a1', 'a2', 'a3', 'a4']);
      final b = leagueItems('B', ['b1', 'b2', 'b3', 'b4']);
      final q1 = MesaScheduler.interleave(queue: const [], newItems: a);
      final q2 = MesaScheduler.interleave(queue: q1, newItems: b);

      expect(q2.length, a.length + b.length);
      expect(consecutiveConflicts(q2), 0);
      // La categoría A conserva su orden relativo.
      final aOrder = q2.where((m) => m.tournamentId == 'A').toList();
      expect(aOrder.map((m) => m.id), q1.map((m) => m.id));
      // Parejas: en la primera mitad de la cola hay encuentros de ambas.
      final firstHalf = q2.take(q2.length ~/ 2);
      expect(firstHalf.where((m) => m.tournamentId == 'B').length,
          greaterThanOrEqualTo(2));
    });

    test('lo ya jugado queda fijo al principio', () {
      final played = [
        item('p1', 'A', 'x', 'y', played: true),
        item('p2', 'A', 'z', 'w', played: true),
      ];
      final b = leagueItems('B', ['b1', 'b2', 'b3', 'b4']);
      final q = MesaScheduler.interleave(queue: played, newItems: b);
      expect(q.take(2).map((m) => m.id), ['p1', 'p2']);
    });

    test('jornadas de liga en orden', () {
      final league = leagueItems('A', ['a1', 'a2', 'a3', 'a4']);
      final q = MesaScheduler.interleave(queue: const [], newItems: league);
      final rounds = q.map((m) => m.round!).toList();
      final firstIdx = {
        for (final r in rounds.toSet()) r: rounds.indexOf(r),
      };
      final sorted = [...firstIdx.keys]..sort();
      final byAppearance = [...firstIdx.keys]
        ..sort((x, y) => firstIdx[x]!.compareTo(firstIdx[y]!));
      expect(byAppearance, sorted);
    });
  });

  group('insertEarliest (ronda nueva de eliminación)', () {
    test('la semifinal va en el primer hueco con descanso', () {
      final queue = [
        item('q1', 'E', 'a', 'b', played: true),
        item('q2', 'E', 'c', 'd', played: true), // ganan a y c
        item('l1', 'L', 'x', 'y'),
        item('l2', 'L', 'z', 'w'),
      ];
      final semi = item('s1', 'E', 'a', 'c', round: 'Semifinal');
      final q = MesaScheduler.insertEarliest(queue: queue, newItems: [semi]);
      // Justo después de q2 chocaría con c → va después de l1.
      expect(q.map((m) => m.id), ['q1', 'q2', 'l1', 's1', 'l2']);
    });

    test('sin otros encuentros en la mesa se relaja la regla y va al final', () {
      final queue = [
        item('s1', 'E', 'a', 'b', played: true),
        item('s2', 'E', 'c', 'd', played: true),
      ];
      final fin = item('f', 'E', 'a', 'c', round: 'Final');
      final third = item('t', 'E', 'b', 'd', round: 'Tercer puesto');
      final q = MesaScheduler.insertEarliest(
          queue: queue, newItems: [third, fin]);
      expect(q.map((m) => m.id), ['s1', 's2', 't', 'f']);
    });

    test('nunca antes de un encuentro ya jugado de su categoría', () {
      // Resultado cargado fuera de orden: q2 (jugado) está detrás de l1
      // (pendiente). La semifinal no puede ir antes de q2.
      final queue = [
        item('q1', 'E', 'a', 'b', played: true),
        item('l1', 'L', 'x', 'y'),
        item('q2', 'E', 'c', 'd', played: true),
        item('l2', 'L', 'z', 'w'),
        item('l3', 'L', 'x', 'z'),
      ];
      final semi = item('s1', 'E', 'a', 'c', round: 'Semifinal');
      final q = MesaScheduler.insertEarliest(queue: queue, newItems: [semi]);
      expect(q.indexWhere((m) => m.id == 's1'),
          greaterThan(q.indexWhere((m) => m.id == 'q2')));
      expect(consecutiveConflicts(q), 0);
    });

    test('los encuentros existentes no cambian su orden relativo', () {
      final queue = [
        item('q1', 'E', 'a', 'b', played: true),
        item('l1', 'L', 'x', 'y'),
        item('l2', 'L', 'z', 'w'),
        item('l3', 'L', 'x', 'z'),
      ];
      final q = MesaScheduler.insertEarliest(
          queue: queue,
          newItems: [item('n1', 'E', 'a', 'k'), item('n2', 'E', 'm', 'n')]);
      expect(q.where((m) => m.tournamentId == 'L').map((m) => m.id),
          ['l1', 'l2', 'l3']);
      expect(q.indexOf(q.firstWhere((m) => m.id == 'n1')),
          lessThan(q.indexOf(q.firstWhere((m) => m.id == 'n2'))));
    });
  });
}
