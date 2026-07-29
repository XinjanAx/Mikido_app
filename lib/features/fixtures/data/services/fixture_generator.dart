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
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
    int timesPlayed = 1,
    int numberOfGroups = 0,
    List<List<String>>? manualGroups,
    List<String>? manualBracketOrder,
  }) {
    switch (mode) {
      case AppConstants.tournamentModeLeague:
        return _generateLeague(tournamentId, playerIds, playerNames,
            timesPlayed: timesPlayed < 1 ? 1 : timesPlayed);
      case AppConstants.tournamentModeElimination:
        return _generateElimination(tournamentId, playerIds, playerNames,
            manualOrder: manualBracketOrder);
      case AppConstants.tournamentModeGroups:
      default:
        if (manualGroups != null) {
          return _generateManualGroups(
              tournamentId, manualGroups, playerIds, playerNames);
        }
        return _generateGroups(tournamentId, playerIds, playerNames,
            numberOfGroups: numberOfGroups);
    }
  }

  /// Liga: round-robin, todos contra todos.
  /// [timesPlayed] indica cuántas veces se enfrenta cada par de jugadores
  /// (1 = una vuelta, 2 = ida y vuelta, etc.).
  static List<MatchModel> _generateLeague(
      String tournamentId, List<String> playerIds, List<String> playerNames,
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

  /// Eliminación simple: cuadro directo. Empareja de a dos en el orden
  /// dado (posiciones 1-2, 3-4, ...); si sobra uno, pasa directo con "bye".
  /// Si no se da [manualOrder], se sortea al azar.
  static List<MatchModel> _generateElimination(
      String tournamentId, List<String> playerIds, List<String> playerNames,
      {List<String>? manualOrder}) {
    final matches = <MatchModel>[];
    int matchNumber = 1;

    final orderedIds = manualOrder ??
        (List<int>.generate(playerIds.length, (i) => i)..shuffle())
            .map((i) => playerIds[i])
            .toList();

    String nameOf(String id) {
      final idx = playerIds.indexOf(id);
      return idx >= 0 ? playerNames[idx] : id;
    }

    for (int i = 0; i < orderedIds.length - 1; i += 2) {
      final homeId = orderedIds[i];
      final awayId = orderedIds[i + 1];
      matches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        homePlayerId: homeId,
        awayPlayerId: awayId,
        homePlayerName: nameOf(homeId),
        awayPlayerName: nameOf(awayId),
        status: AppConstants.matchStatusPending,
        round: _eliminationRoundName(playerIds.length),
        matchNumber: matchNumber++,
      ));
    }

    if (orderedIds.length.isOdd) {
      final byeId = orderedIds.last;
      matches.add(MatchModel(
        id: const Uuid().v4(),
        tournamentId: tournamentId,
        homePlayerId: byeId,
        awayPlayerId: byeId, // mismo jugador = bye
        homePlayerName: nameOf(byeId),
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

  /// Por grupos (modo aleatorio): sortea a los jugadores y los reparte en
  /// [numberOfGroups] grupos lo más parejo posible (si sobran jugadores,
  /// los primeros grupos llevan uno extra), luego hace round-robin dentro
  /// de cada grupo. Si no se especifica un número de grupos (<= 0), se
  /// calcula automáticamente para que cada grupo tenga como máximo 4
  /// jugadores.
  static List<MatchModel> _generateGroups(
      String tournamentId, List<String> playerIds, List<String> playerNames,
      {int numberOfGroups = 0}) {
    final n = playerIds.length;

    // Sortear manteniendo alineados id y nombre.
    final order = List<int>.generate(n, (i) => i)..shuffle();
    final shuffledIds = [for (final i in order) playerIds[i]];
    final shuffledNames = [for (final i in order) playerNames[i]];

    const maxGroupSizeFallback = 4;
    final groups = numberOfGroups > 0
        ? numberOfGroups.clamp(1, n)
        : (n / maxGroupSizeFallback).ceil().clamp(1, n);

    final baseSize = n ~/ groups;
    final remainder = n % groups;

    final manualGroups = <List<String>>[];
    int start = 0;
    for (int g = 0; g < groups; g++) {
      // Los primeros `remainder` grupos llevan un jugador extra.
      final size = baseSize + (g < remainder ? 1 : 0);
      final end = (start + size).clamp(0, n);
      if (start >= end) break; // sin jugadores suficientes para este grupo
      manualGroups.add(shuffledIds.sublist(start, end));
      start = end;
    }

    return _generateManualGroups(
        tournamentId, manualGroups, shuffledIds, shuffledNames);
  }

  /// Por grupos (modo manual): usa exactamente la agrupación indicada por
  /// el admin (por ejemplo, armada arrastrando jugadores en la pantalla de
  /// asignación) en vez de calcularla automáticamente.
  static List<MatchModel> _generateManualGroups(
      String tournamentId,
      List<List<String>> manualGroups,
      List<String> playerIds,
      List<String> playerNames) {
    final matches = <MatchModel>[];
    int matchNumber = 1;

    for (int g = 0; g < manualGroups.length; g++) {
      final groupIds = manualGroups[g];
      final groupLabel = String.fromCharCode(65 + g); // A, B, C...

      for (int i = 0; i < groupIds.length; i++) {
        for (int j = i + 1; j < groupIds.length; j++) {
          final homeId = groupIds[i];
          final awayId = groupIds[j];
          final homeIdx = playerIds.indexOf(homeId);
          final awayIdx = playerIds.indexOf(awayId);
          matches.add(MatchModel(
            id: const Uuid().v4(),
            tournamentId: tournamentId,
            homePlayerId: homeId,
            awayPlayerId: awayId,
            homePlayerName: homeIdx >= 0 ? playerNames[homeIdx] : homeId,
            awayPlayerName: awayIdx >= 0 ? playerNames[awayIdx] : awayId,
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
