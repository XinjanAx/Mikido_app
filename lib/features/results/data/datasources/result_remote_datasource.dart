import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/result_model.dart';

/// CRUD puro contra Supabase. Guardar un resultado (actualizar el partido +
/// recalcular posiciones) ahora vive en MatchResultService, operando sobre
/// la base local — este datasource solo lo usa el motor de sincronización.
abstract class ResultRemoteDataSource {
  Future<List<ResultModel>> getResultsByTournament(String tournamentId);
  Future<ResultModel?> getResultByMatch(String matchId);

  /// Todos los resultados (todos los torneos), usado por el motor de
  /// sincronización para reconciliar la base local.
  Future<List<ResultModel>> getAllResults();

  /// Upsert idempotente (por `match_id`) usado por el motor de
  /// sincronización.
  Future<ResultModel> upsertResult(ResultModel result);
}

class ResultRemoteDataSourceImpl implements ResultRemoteDataSource {
  final SupabaseClient _client;
  const ResultRemoteDataSourceImpl(this._client);

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

  @override
  Future<List<ResultModel>> getAllResults() async {
    try {
      final data =
          await _client.from(SupabaseConstants.resultsTable).select();
      return (data as List).map((e) => ResultModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener resultados: $e');
    }
  }

  @override
  Future<ResultModel> upsertResult(ResultModel result) async {
    try {
      final data = await _client
          .from(SupabaseConstants.resultsTable)
          .upsert(result.toJson(), onConflict: 'match_id')
          .select()
          .single();
      return ResultModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar resultado: $e');
    }
  }
}
