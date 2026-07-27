import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/match_model.dart';

abstract class FixtureRemoteDataSource {
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId,
      {String? categoryId});
  Future<List<MatchModel>> generateFixture({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
  });
  Future<MatchModel> updateMatchResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  });
  Stream<List<MatchModel>> watchMatches(String tournamentId);
}

class FixtureRemoteDataSourceImpl implements FixtureRemoteDataSource {
  final SupabaseClient _client;
  const FixtureRemoteDataSourceImpl(this._client);

  @override
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId,
      {String? categoryId}) async {
    try {
      var query = _client
          .from(SupabaseConstants.matchesTable)
          .select()
          .eq('tournament_id', tournamentId);
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      final data = await query.order('match_number');
      return (data as List).map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener partidos: $e');
    }
  }

  @override
  Future<List<MatchModel>> generateFixture({
    required String tournamentId,
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
  }) async {
    try {
      // Eliminar fixture anterior para esta categoría
      await _client
          .from(SupabaseConstants.matchesTable)
          .delete()
          .eq('tournament_id', tournamentId)
          .eq('category_id', categoryId);

      List<MatchModel> matches;

      switch (mode) {
        case AppConstants.tournamentModeLeague:
          matches = _generateLeague(
              tournamentId, categoryId, playerIds, playerNames);
          break;
        case AppConstants.tournamentModeElimination:
          matches = _generateElimination(
              tournamentId, categoryId, playerIds, playerNames);
          break;
        case AppConstants.tournamentModeGroups:
        default:
          matches = _generateGroups(
              tournamentId, categoryId, playerIds, playerNames);
      }

      // Insertar todos los partidos
      final insertData =
          matches.map((m) => m.toInsertJson()).toList();
      final inserted =
          await _client.from(SupabaseConstants.matchesTable).insert(insertData).select();
      return (inserted as List).map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al generar fixture: $e');
    }
  }

  /// Liga: round-robin, todos contra todos
  List<MatchModel> _generateLeague(String tournamentId, String categoryId,
      List<String> playerIds, List<String> playerNames) {
    final matches = <MatchModel>[];
    int matchNumber = 1;
    final players = List<String>.from(playerIds);
    final names = List<String>.from(playerNames);

    // Si número impar, agregar "bye"
    if (players.length % 2 != 0) {
      players.add('bye');
      names.add('Libre');
    }
    final n = players.length;
    final rounds = n - 1;
    final halfN = n ~/ 2;

    for (int r = 0; r < rounds; r++) {
      for (int m = 0; m < halfN; m++) {
        final home = players[m];
        final away = players[n - 1 - m];
        if (home != 'bye' && away != 'bye') {
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
            round: 'Jornada ${r + 1}',
            matchNumber: matchNumber++,
          ));
        }
      }
      // Rotar (excepto primer elemento)
      final last = players.removeLast();
      players.insert(1, last);
    }
    return matches;
  }

  /// Eliminación simple: cuadro directo
  List<MatchModel> _generateElimination(String tournamentId, String categoryId,
      List<String> playerIds, List<String> playerNames) {
    final matches = <MatchModel>[];
    int matchNumber = 1;

    // Sortear jugadores
    final shuffled = List<int>.generate(playerIds.length, (i) => i)..shuffle();

    // Primera ronda - emparejar
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

    // Si número impar, el último pasa directo (bye)
    // Las rondas siguientes se crean conforme se registran resultados
    return matches;
  }

  String _eliminationRoundName(int totalPlayers) {
    if (totalPlayers >= 16) return 'Octavos de final';
    if (totalPlayers >= 8) return 'Cuartos de final';
    if (totalPlayers >= 4) return 'Semifinal';
    return 'Final';
  }

  /// Por grupos: dividir en grupos de ~4 y hacer round-robin por grupo
  List<MatchModel> _generateGroups(String tournamentId, String categoryId,
      List<String> playerIds, List<String> playerNames) {
    final matches = <MatchModel>[];
    int matchNumber = 1;

    // Dividir en grupos de máximo 4
    const groupSize = 4;
    final numGroups = (playerIds.length / groupSize).ceil();

    for (int g = 0; g < numGroups; g++) {
      final start = g * groupSize;
      final end =
          (start + groupSize).clamp(0, playerIds.length);
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

  @override
  Future<MatchModel> updateMatchResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    try {
      final data = await _client
          .from(SupabaseConstants.matchesTable)
          .update({
            'home_score': homeScore,
            'away_score': awayScore,
            'status': AppConstants.matchStatusFinished,
          })
          .eq('id', matchId)
          .select()
          .single();
      return MatchModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar resultado: $e');
    }
  }

  @override
  Stream<List<MatchModel>> watchMatches(String tournamentId) {
    return _client
        .from(SupabaseConstants.matchesTable)
        .stream(primaryKey: ['id'])
        .eq('tournament_id', tournamentId)
        .order('match_number')
        .map((data) => data.map((e) => MatchModel.fromJson(e)).toList());
  }
}
