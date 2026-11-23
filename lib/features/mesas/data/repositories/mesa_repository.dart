import 'dart:async';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/entities/mesa_entity.dart';
import '../datasources/mesa_local_datasource.dart';
import '../datasources/mesa_remote_datasource.dart';
import '../models/mesa_model.dart';

/// Repositorio local-first de mesas: lee de la base local y cada escritura
/// se guarda local + se encola en el outbox, igual que las categorías.
class MesaRepository {
  final MesaLocalDataSource _local;
  final MesaRemoteDataSource _remote;
  final AppDatabase _db;
  final SyncEngine _syncEngine;

  const MesaRepository(this._local, this._remote, this._db, this._syncEngine);

  Stream<List<MesaEntity>> watchMesas() => _local.watchMesas();

  Future<void> save(MesaEntity mesa) async {
    final model = MesaModel.fromEntity(mesa);
    await _local.upsert(model, dirty: true);
    await _db.enqueueUpsert(
        SupabaseConstants.mesasTable, model.id, model.toJson());
    unawaited(_syncEngine.trySync());
  }

  /// Solo se puede borrar una mesa sin categorías. Se comprueba en la base
  /// local y, si hay conexión, también en el servidor: el dispositivo puede
  /// no haber bajado todavía categorías que otro admin creó (o que se
  /// asignaron a la mesa desde Supabase). Sin conexión se decide con lo
  /// local; si el servidor después rechaza el borrado, MesaSyncAdapter
  /// devuelve la mesa a la lista.
  Future<bool> delete(String id) async {
    final categories = await _db.getTournamentsByMesa(id);
    if (categories.isNotEmpty) return false;
    final remoteCount = await _remote.countCategories(id);
    if (remoteCount != null && remoteCount > 0) return false;
    await _local.softDelete(id);
    await _db.enqueueDelete(SupabaseConstants.mesasTable, id);
    unawaited(_syncEngine.trySync());
    return true;
  }
}
