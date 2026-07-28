import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/standing_model.dart';

/// CRUD puro contra Supabase. El cálculo de la tabla de posiciones vive en
/// StandingsRecalculationService, operando sobre la base local — este
/// datasource solo lo usa el motor de sincronización para subir/bajar filas.
abstract class StandingRemoteDataSource {
  Future<List<StandingModel>> getStandings(String tournamentId,
      {String? categoryId});

  /// Todas las posiciones (todos los torneos), usado por el motor de
  /// sincronización para reconciliar la base local.
  Future<List<StandingModel>> getAllStandings();

  /// Upsert idempotente usado por el motor de sincronización.
  Future<StandingModel> upsertStanding(StandingModel standing);

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
  Future<List<StandingModel>> getAllStandings() async {
    try {
      final data =
          await _client.from(SupabaseConstants.standingsTable).select();
      return (data as List).map((e) => StandingModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener posiciones: $e');
    }
  }

  @override
  Future<StandingModel> upsertStanding(StandingModel standing) async {
    try {
      final data = await _client
          .from(SupabaseConstants.standingsTable)
          .upsert(standing.toJson())
          .select()
          .single();
      return StandingModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar posición: $e');
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
