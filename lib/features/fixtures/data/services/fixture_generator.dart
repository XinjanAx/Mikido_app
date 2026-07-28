import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/match_model.dart';

/// Generación pura de partidos según la modalidad del torneo. No toca
/// ninguna base de datos — el repositorio decide dónde guardar el
/// resultado (antes Supabase directo, ahora la base local).
class FixtureGenerator {
  FixtureGenerator._();

  static List<MatchModel> generate({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
    int timesPlayed = 1,
  }) {
    switch (mode) {
      case AppConstants.tournamentModeLeague:
        return _generateLeague(tournamentId, categoryId, playerIds, playerNames,
            timesPlayed: timesPlayed < 1 ? 1 : timesPlayed);
      case AppConstants.tournamentModeElimination:
        return _generateElimination(
            tournamentId, categoryId, playerIds, playerNames);
      case AppConstants.tournamentModeGroups:
      default:
        return _generateGroups(
            tournamentId, categoryId, playerIds, playerNames);
    }
  }

  /// Liga: round-robin, todos contra todos.
  /// [timesPlayed] indica cuántas veces se enfrenta cada par de jugadores
  /// (1 = una vuelta, 2 = ida y vuelta, etc.).
  static List<MatchModel> _generateLeague(String tournamentId,
      String categoryId, List<String> playerIds, List<String> playerNames,
      {int timesPlayed = 1}) {
    final matches = <MatchModel>[];
    int matchNumber = 1;
    final rotation = List<String>.from(playerIds);

    // Si número impar, agregar "bye" para completar las jornadas
    if (rotation.length % 2 != 0) {
      rotation.add('bye');
    }
    final n = rotation.length;
    final roundsPerCycle = n - 1;
    final halfN = n ~/ 2;

    // Calcular los enfrentamientos de una vuelta completa (método del círculo)
    final cyclePairs = <List<(String, String)>>[];
    for (int r = 0; r < roundsPerCycle; r++) {
      final roundPairs = <(String, String)>[];
      for (int m = 0; m < halfN; m++) {
        final home = rotation[m];
        final away = rotation[n - 1 - m];
        if (home != 'bye' && away != 'bye') {
          roundPairs.add((home, away));
        }
      }
      cyclePairs.add(roundPairs);
      // Rotar (excepto primer elemento)
      final last = rotation.removeLast();
      rotation.insert(1, last);
    }

    for (int t = 0; t < timesPlayed; t++) {
      // A partir de la segunda vuelta se invierte localía para que
      // cada jugador enfrente al mismo rival tanto de local como de visita.
      final swapHomeAway = t.isOdd;
      for (int r = 0; r < cyclePairs.length; r++) {
        for (final pair in cyclePairs[r]) {
          final home = swapHomeAway ? pair.$2 : pair.$1;
          final away = swapHomeAway ? pair.$1 : pair.$2;
          final homeIdx = playerIds.indexOf(home);
          final awayIdx = playerIds.indexOf(away);
          matches.add(MatchModel(
            id: const Uuid().v4(),
            tournamentId: tournamentId,
            categoryId: categoryId,
            homePlayerId: home,
            awayPlayerId: away,
            homePlayerName: homeIdx >= 0 ? playerNames[homeIdx] : home,
            awayPlayerName: awayIdx >= 0 ? playerNames[awayIdx] : away,
            status: AppConstants.matchStatusPending,
            round: timesPlayed > 1
                ? 'Vuelta ${t + 1} - Jornada ${r + 1}'
                : 'Jornada ${r + 1}',
            matchNumber: matchNumber++,
          ));
        }
      }
    }
    return matches;
  }

  /// Eliminación simple: cuadro directo
  static List<MatchModel> _generateElimination(String tournamentId,
      String categoryId, List<String> playerIds, List<String> playerNames) {
    final matches = <MatchModel>[];
    int matchNumber = 1;

    // Sortear jugadores
    final shuffled = List<int>.generate(playerIds.length, (i) => i)..shuffle();

    // Emparejar de a dos; si sobra uno, pasa directo con un "bye"
    for (int i = 0; i < shuffled.length - 1; i += 2) {
      final homeIdx = shuffled[i];
      final awayIdx = shuffled[i + 1];
      matches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        categoryId: categoryId,
        homePlayerId: playerIds[homeIdx],
        awayPlayerId: playerIds[awayIdx],
        homePlayerName: playerNames[homeIdx],
        awayPlayerName: playerNames[awayIdx],
        status: AppConstants.matchStatusPending,
        round: _eliminationRoundName(playerIds.length),
        matchNumber: matchNumber++,
      ));
    }

    if (shuffled.length.isOdd) {
      final byeIdx = shuffled.last;
      matches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        categoryId: categoryId,
        homePlayerId: playerIds[byeIdx],
        awayPlayerId: playerIds[byeIdx], // mismo jugador = bye
        homePlayerName: playerNames[byeIdx],
        awayPlayerName: 'BYE',
        homeScore: 1,
        awayScore: 0,
        status: AppConstants.matchStatusFinished,
        round: _eliminationRoundName(playerIds.length),
        matchNumber: matchNumber++,
      ));
    }

    return matches;
  }

  static String _eliminationRoundName(int totalPlayers) {
    if (totalPlayers >= 16) return 'Octavos de final';
    if (totalPlayers >= 8) return 'Cuartos de final';
    if (totalPlayers >= 4) return 'Semifinal';
    return 'Final';
  }

  /// Por grupos: dividir en grupos de ~4 y hacer round-robin por grupo
  static List<MatchModel> _generateGroups(String tournamentId,
      String categoryId, List<String> playerIds, List<String> playerNames) {
    final matches = <MatchModel>[];
    int matchNumber = 1;

    // Dividir en grupos de máximo 4
    const groupSize = 4;
    final numGroups = (playerIds.length / groupSize).ceil();

    for (int g = 0; g < numGroups; g++) {
      final start = g * groupSize;
      final end = (start + groupSize).clamp(0, playerIds.length);
      final groupPlayers = playerIds.sublist(start, end);
      final groupNames = playerNames.sublist(start, end);
      final groupLabel = String.fromCharCode(65 + g); // A, B, C...

      // Round-robin dentro del grupo
      for (int i = 0; i < groupPlayers.length; i++) {
        for (int j = i + 1; j < groupPlayers.length; j++) {
          matches.add(MatchModel(
            id: const Uuid().v4(),
            tournamentId: tournamentId,
            categoryId: categoryId,
            homePlayerId: groupPlayers[i],
            awayPlayerId: groupPlayers[j],
            homePlayerName: groupNames[i],
            awayPlayerName: groupNames[j],
            status: AppConstants.matchStatusPending,
            round: 'Grupo $groupLabel',
            matchNumber: matchNumber++,
          ));
        }
      }
    }
    return matches;
  }
}
