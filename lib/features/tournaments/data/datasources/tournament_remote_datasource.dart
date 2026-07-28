import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/tournament_model.dart';

abstract class TournamentRemoteDataSource {
  Future<List<TournamentModel>> getTournaments();
  Future<TournamentModel> getTournamentById(String id);
  Future<TournamentModel> createTournament(TournamentModel tournament);
  Future<TournamentModel> updateTournament(TournamentModel tournament);
  Future<void> deleteTournament(String id);
  Stream<List<TournamentModel>> watchTournaments();

  /// Upsert idempotente (crea o actualiza) usado por el motor de
  /// sincronización, que puede reintentar la misma operación tras un fallo.
  Future<TournamentModel> upsertTournament(TournamentModel tournament);
}

class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final SupabaseClient _client;

  const TournamentRemoteDataSourceImpl(this._client);

  @override
  Future<List<TournamentModel>> getTournaments() async {
    try {
      final data = await _client
          .from(SupabaseConstants.tournamentsTable)
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((e) => TournamentModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener torneos: $e');
    }
  }

  @override
  Future<TournamentModel> getTournamentById(String id) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tournamentsTable)
          .select()
          .eq('id', id)
          .single();
      return TournamentModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Torneo no encontrado: $e');
    }
  }

  @override
  Future<TournamentModel> createTournament(TournamentModel tournament) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tournamentsTable)
          .insert(tournament.toInsertJson())
          .select()
          .single();
      return TournamentModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al crear torneo: $e');
    }
  }

  @override
  Future<TournamentModel> updateTournament(TournamentModel tournament) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tournamentsTable)
          .update(tournament.toJson())
          .eq('id', tournament.id)
          .select()
          .single();
      return TournamentModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al actualizar torneo: $e');
    }
  }

  @override
  Future<TournamentModel> upsertTournament(TournamentModel tournament) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tournamentsTable)
          .upsert(tournament.toJson())
          .select()
          .single();
      return TournamentModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar torneo: $e');
    }
  }

  @override
  Future<void> deleteTournament(String id) async {
    try {
      await _client
          .from(SupabaseConstants.tournamentsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw ServerException(message: 'Error al eliminar torneo: $e');
    }
  }

  @override
  Stream<List<TournamentModel>> watchTournaments() {
    return _client
        .from(SupabaseConstants.tournamentsTable)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => TournamentModel.fromJson(e)).toList());
  }
}
