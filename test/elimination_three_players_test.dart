import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/constants/app_constants.dart';
import 'package:torneo_app/core/database/app_database.dart';
import 'package:torneo_app/features/fixtures/data/datasources/fixture_local_datasource.dart';
import 'package:torneo_app/features/fixtures/data/models/match_model.dart';
import 'package:torneo_app/features/fixtures/data/services/elimination_bracket_service.dart';
import 'package:torneo_app/features/fixtures/data/services/fixture_generator.dart';
import 'package:torneo_app/features/mesas/data/services/mesa_schedule_service.dart';

/// Datasource en memoria: solo lo que usa checkRoundComplete.
class _FakeLocal implements FixtureLocalDataSource {
  final List<MatchModel> matches;
  _FakeLocal(this.matches);

  @override
  Future<List<MatchModel>> getMatchesByRound(String t, String round) async =>
      matches.where((m) => m.tournamentId == t && m.round == round).toList();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Eliminación simple con 3 participantes (si el admin ignora la advertencia).
void main() {
  test('eliminación simple con 3 participantes', () async {
    final generated = FixtureGenerator.generate(
      tournamentId: 'T',
      mode: AppConstants.tournamentModeElimination,
      playerIds: ['A', 'B', 'C'],
      playerNames: ['Ana', 'Beto', 'Caro'],
      manualBracketOrder: ['A', 'B', 'C'], // A = sembrado 1
    );

    // Cuadro de 4: A pasa directo (BYE) y B vs C juegan la "Semifinal".
    expect(generated.length, 2);
    expect(generated.every((m) => m.round == 'Semifinal'), isTrue);
    final bye = generated.firstWhere((m) => m.isBye);
    final real = generated.firstWhere((m) => !m.isBye);
    expect(bye.homePlayerId, 'A');
    expect({real.homePlayerId, real.awayPlayerId}, {'B', 'C'});

    // Se juega B vs C: gana B.
    final played = MatchModel(
      id: real.id,
      tournamentId: 'T',
      homePlayerId: real.homePlayerId,
      awayPlayerId: real.awayPlayerId,
      homePlayerName: real.homePlayerName,
      awayPlayerName: real.awayPlayerName,
      homeScore: real.homePlayerId == 'B' ? 2 : 1,
      awayScore: real.homePlayerId == 'B' ? 1 : 2,
      status: AppConstants.matchStatusFinished,
      round: real.round,
      matchNumber: real.matchNumber,
    );

    final local = _FakeLocal([bye, played]);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final service = EliminationBracketService(
        local, db, MesaScheduleService(local, db));

    final pending = await service.checkRoundComplete(
        tournamentId: 'T', completedRound: 'Semifinal');

    expect(pending, isNotNull);
    expect(pending!.nextRound, 'Final');
    expect(pending.winners.map((w) => w.id).toSet(), {'A', 'B'});

    // Con un BYE en la semifinal no se arma 3er puesto (antes salía un
    // "BYE vs Caro" contra la finalista Ana). C queda tercero.
    expect(pending.thirdPlacePlayers, isNull);
    await db.close();
  });
}
