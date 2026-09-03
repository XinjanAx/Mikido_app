import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/match_model.dart';

/// CRUD puro contra Supabase. La generación de fixtures, el avance de
/// bracket y el recálculo de posiciones viven en la base local (ver
/// FixtureGenerator, EliminationBracketService y MatchResultService) — este
/// datasource solo lo usa el motor de sincronización para subir/bajar filas.
abstract class FixtureRemoteDataSource {
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId);

  /// Todos los partidos (todos los torneos), usado por el motor de
  /// sincronización para reconciliar la base local.
  Future<List<MatchModel>> getAllMatches();

  /// Upsert idempotente usado por el motor de sincronización.
  Future<MatchModel> upsertMatch(MatchModel match);

  Future<void> deleteMatch(String id);

  /// Borrado directo e inmediato de TODOS los partidos de un torneo,
  /// usado al regenerar/eliminar el fixture en vez de depender solo del
  /// outbox (que puede tardar en sincronizar o, si falla en silencio,
  /// dejar filas "fantasma" que resucitan en el próximo pull).
  Future<void> deleteMatchesByTournament(String tournamentId);

  Stream<List<MatchModel>> watchMatches(String tournamentId);
}

class FixtureRemoteDataSourceImpl implements FixtureRemoteDataSource {
  final SupabaseClient _client;
  const FixtureRemoteDataSourceImpl(this._client);

  @override
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.matchesTable)
          .select()
          .eq('tournament_id', tournamentId)
          .order('match_number');
      return (data as List).map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener partidos: $e');
    }
  }

  @override
  Future<List<MatchModel>> getAllMatches() async {
    try {
      final data = await _client.from(SupabaseConstants.matchesTable).select();
      return (data as List).map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener partidos: $e');
    }
  }

  @override
  Future<MatchModel> upsertMatch(MatchModel match) async {
    try {
      final data = await _client
          .from(SupabaseConstants.matchesTable)
          .upsert(match.toJson())
          .select()
          .single();
      return MatchModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar partido: $e');
    }
  }

  @override
  Future<void> deleteMatch(String id) async {
    try {
      await _client.from(SupabaseConstants.matchesTable).delete().eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar partido: $e');
    }
  }

  @override
  Future<void> deleteMatchesByTournament(String tournamentId) async {
    try {
      await _client
          .from(SupabaseConstants.matchesTable)
          .delete()
          .eq('tournament_id', tournamentId);
    } catch (e) {
      throw ServerException(
          message: 'Error al eliminar partidos del torneo: $e');
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
