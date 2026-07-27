import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/result_model.dart';

abstract class ResultRemoteDataSource {
  Future<ResultModel> registerResult({
    required String matchId,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    required String registeredBy,
    String? notes,
  });

  Future<List<ResultModel>> getResultsByTournament(String tournamentId);
  Future<ResultModel?> getResultByMatch(String matchId);
}

class ResultRemoteDataSourceImpl implements ResultRemoteDataSource {
  final SupabaseClient _client;
  const ResultRemoteDataSourceImpl(this._client);

  @override
  Future<ResultModel> registerResult({
    required String matchId,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    required String registeredBy,
    String? notes,
  }) async {
    try {
      // 1. Insertar/actualizar resultado en tabla results
      final resultData = await _client
          .from(SupabaseConstants.resultsTable)
          .upsert({
            'id': const Uuid().v4(),
            'match_id': matchId,
            'tournament_id': tournamentId,
            'home_player_id': homePlayerId,
            'away_player_id': awayPlayerId,
            'home_score': homeScore,
            'away_score': awayScore,
            'notes': notes,
            'registered_by': registeredBy,
            'registered_at': DateTime.now().toIso8601String(),
          }, onConflict: 'match_id')
          .select()
          .single();

      // 2. Actualizar el partido con el resultado y marcarlo como finalizado
      await _client
          .from(SupabaseConstants.matchesTable)
          .update({
            'home_score': homeScore,
            'away_score': awayScore,
            'status': AppConstants.matchStatusFinished,
          })
          .eq('id', matchId);

      // 3. Recalcular posiciones via RPC (función PostgreSQL en Supabase)
      try {
        await _client.rpc('recalculate_standings',
            params: {'p_tournament_id': tournamentId});
      } catch (_) {
        // Si la RPC no está disponible, continuar sin error crítico
      }

      return ResultModel.fromJson(resultData);
    } catch (e) {
      throw ServerException(message: 'Error al registrar resultado: $e');
    }
  }

  @override
  Future<List<ResultModel>> getResultsByTournament(
      String tournamentId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.resultsTable)
          .select()
          .eq('tournament_id', tournamentId)
          .order('registered_at', ascending: false);
      return (data as List).map((e) => ResultModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener resultados: $e');
    }
  }

  @override
  Future<ResultModel?> getResultByMatch(String matchId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.resultsTable)
          .select()
          .eq('match_id', matchId)
          .maybeSingle();
      if (data == null) return null;
      return ResultModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al obtener resultado: $e');
    }
  }
}
