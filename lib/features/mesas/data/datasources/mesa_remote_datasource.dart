import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/mesa_model.dart';

/// CRUD contra Supabase, usado solo por el motor de sincronización.
abstract class MesaRemoteDataSource {
  Future<List<MesaModel>> getMesas();
  Future<void> upsertMesa(MesaModel mesa);

  /// Lanza [StillReferencedException] si la mesa todavía tiene categorías
  /// en el servidor.
  Future<void> deleteMesa(String id);

  /// Cantidad de categorías de la mesa según el servidor, o null si no se
  /// pudo consultar (sin red).
  Future<int?> countCategories(String mesaId);
}

class MesaRemoteDataSourceImpl implements MesaRemoteDataSource {
  final SupabaseClient _client;
  const MesaRemoteDataSourceImpl(this._client);

  @override
  Future<List<MesaModel>> getMesas() async {
    try {
      final data = await _client
          .from(SupabaseConstants.mesasTable)
          .select()
          .order('created_at');
      return (data as List)
          .map((e) => MesaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener mesas: $e');
    }
  }

  @override
  Future<void> upsertMesa(MesaModel mesa) async {
    try {
      await _client.from(SupabaseConstants.mesasTable).upsert(mesa.toJson());
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar mesa: $e');
    }
  }

  @override
  Future<void> deleteMesa(String id) async {
    try {
      await _client.from(SupabaseConstants.mesasTable).delete().eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw StillReferencedException(
            message: 'La mesa todavía tiene categorías: ${e.message}');
      }
      throw ServerException(message: 'Error al eliminar mesa: $e');
    } catch (e) {
      throw ServerException(message: 'Error al eliminar mesa: $e');
    }
  }

  @override
  Future<int?> countCategories(String mesaId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tournamentsTable)
          .select('id')
          .eq('mesa_id', mesaId)
          .timeout(const Duration(seconds: 5));
      return (data as List).length;
    } catch (_) {
      return null; // sin red: se decide solo con los datos locales
    }
  }
}
