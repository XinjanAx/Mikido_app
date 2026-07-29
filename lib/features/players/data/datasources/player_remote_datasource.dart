import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/player_model.dart';

abstract class PlayerRemoteDataSource {
  Future<List<PlayerModel>> getPlayers();
  Future<PlayerModel> getPlayerById(String id);
  Future<PlayerModel> createPlayer(PlayerModel player);
  Future<PlayerModel> updatePlayer(PlayerModel player);
  Future<void> deletePlayer(String id);
  Future<void> enrollPlayer({
    required String playerId,
    required String tournamentId,
  });
  Future<void> unenrollPlayer({
    required String playerId,
    required String tournamentId,
  });
  Future<List<PlayerModel>> getPlayersByTournament(String tournamentId);

  /// Upsert idempotente usado por el motor de sincronización.
  Future<PlayerModel> upsertPlayer(PlayerModel player);

  /// Filas crudas de `enrollments` (todos los torneos), usado por el motor
  /// de sincronización para reconciliar la base local.
  Future<List<Map<String, dynamic>>> getAllEnrollments();
}

class PlayerRemoteDataSourceImpl implements PlayerRemoteDataSource {
  final SupabaseClient _client;
  const PlayerRemoteDataSourceImpl(this._client);

  @override
  Future<List<PlayerModel>> getPlayers() async {
    try {
      final data = await _client
          .from(SupabaseConstants.playersTable)
          .select()
          .order('name');
      return (data as List).map((e) => PlayerModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener participantes: $e');
    }
  }

  @override
  Future<PlayerModel> getPlayerById(String id) async {
    try {
      final data = await _client
          .from(SupabaseConstants.playersTable)
          .select()
          .eq('id', id)
          .single();
      return PlayerModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Participante no encontrado: $e');
    }
  }

  @override
  Future<PlayerModel> createPlayer(PlayerModel player) async {
    try {
      final data = await _client
          .from(SupabaseConstants.playersTable)
          .insert(player.toInsertJson())
          .select()
          .single();
      return PlayerModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al crear participante: $e');
    }
  }

  @override
  Future<PlayerModel> updatePlayer(PlayerModel player) async {
    try {
      final data = await _client
          .from(SupabaseConstants.playersTable)
          .update(player.toJson())
          .eq('id', player.id)
          .select()
          .single();
      return PlayerModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar participante: $e');
    }
  }

  @override
  Future<void> deletePlayer(String id) async {
    try {
      await _client.from(SupabaseConstants.playersTable).delete().eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar participante: $e');
    }
  }

  @override
  Future<void> enrollPlayer({
    required String playerId,
    required String tournamentId,
  }) async {
    try {
      await _client.from(SupabaseConstants.enrollmentsTable).upsert({
        'player_id': playerId,
        'tournament_id': tournamentId,
      });
    } catch (e) {
      throw ServerException(message: 'Error al inscribir participante: $e');
    }
  }

  @override
  Future<void> unenrollPlayer({
    required String playerId,
    required String tournamentId,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.enrollmentsTable)
          .delete()
          .eq('player_id', playerId)
          .eq('tournament_id', tournamentId);
    } catch (e) {
      throw ServerException(message: 'Error al desinscribir participante: $e');
    }
  }

  @override
  Future<PlayerModel> upsertPlayer(PlayerModel player) async {
    try {
      final data = await _client
          .from(SupabaseConstants.playersTable)
          .upsert(player.toJson())
          .select()
          .single();
      return PlayerModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar participante: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllEnrollments() async {
    try {
      final data =
          await _client.from(SupabaseConstants.enrollmentsTable).select();
      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw ServerException(message: 'Error al obtener inscripciones: $e');
    }
  }

  @override
  Future<List<PlayerModel>> getPlayersByTournament(String tournamentId) async {
    try {
      final enrollments = await _client
          .from(SupabaseConstants.enrollmentsTable)
          .select('player_id')
          .eq('tournament_id', tournamentId);

      if ((enrollments as List).isEmpty) return [];

      final playerIds =
          enrollments.map((e) => e['player_id'] as String).toList();

      final players = await _client
          .from(SupabaseConstants.playersTable)
          .select()
          .inFilter('id', playerIds);

      return (players as List).map((e) => PlayerModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(
          message: 'Error al obtener participantes del torneo: $e');
    }
  }
}
