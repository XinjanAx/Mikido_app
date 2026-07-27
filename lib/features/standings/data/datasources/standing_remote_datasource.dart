import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/standing_model.dart';

abstract class StandingRemoteDataSource {
  Future<List<StandingModel>> getStandings(String tournamentId,
      {String? categoryId});
  Future<void> recalculateStandings(String tournamentId);
  Stream<List<StandingModel>> watchStandings(String tournamentId);
}

class StandingRemoteDataSourceImpl implements StandingRemoteDataSource {
  final SupabaseClient _client;
  const StandingRemoteDataSourceImpl(this._client);

  @override
  Future<List<StandingModel>> getStandings(String tournamentId,
      {String? categoryId}) async {
    try {
      var query = _client
          .from(SupabaseConstants.standingsTable)
          .select()
          .eq('tournament_id', tournamentId);
      if (categoryId != null) query = query.eq('category_id', categoryId);
      final data = await query.order('points', ascending: false);
      return (data as List).map((e) => StandingModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener posiciones: $e');
    }
  }

  @override
  Future<void> recalculateStandings(String tournamentId) async {
    // La recalculación se hace vía Supabase Function o RPC
    // Se puede implementar como una función PostgreSQL que se llama aquí
    try {
      await _client.rpc('recalculate_standings',
          params: {'p_tournament_id': tournamentId});
    } catch (e) {
      throw ServerException(message: 'Error al recalcular posiciones: $e');
    }
  }

  @override
  Stream<List<StandingModel>> watchStandings(String tournamentId) {
    return _client
        .from(SupabaseConstants.standingsTable)
        .stream(primaryKey: ['id'])
        .eq('tournament_id', tournamentId)
        .order('points', ascending: false)
        .map((data) => data.map((e) => StandingModel.fromJson(e)).toList());
  }
}
