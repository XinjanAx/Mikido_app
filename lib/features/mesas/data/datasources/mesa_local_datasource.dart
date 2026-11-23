import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/mesa_model.dart';

abstract class MesaLocalDataSource {
  Future<List<MesaModel>> getMesas();
  Future<MesaModel?> getMesaById(String id);
  Stream<List<MesaModel>> watchMesas();

  /// [dirty] indica si el cambio se originó localmente (pendiente de subir)
  /// o viene de un pull remoto.
  Future<void> upsert(MesaModel mesa, {required bool dirty});
  Future<bool> isDirty(String id);
  Future<void> markSynced(String id);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);

  /// Deshace un [softDelete] (el servidor rechazó el borrado).
  Future<void> restore(String id);
}

class MesaLocalDataSourceImpl implements MesaLocalDataSource {
  final AppDatabase _db;
  const MesaLocalDataSourceImpl(this._db);

  MesaModel _toModel(Mesa row) => MesaModel(
        id: row.id,
        name: row.name,
        description: row.description,
        createdBy: row.createdBy,
        createdAt: row.createdAt,
      );

  @override
  Future<List<MesaModel>> getMesas() async =>
      (await _db.getAllMesas()).map(_toModel).toList();

  @override
  Future<MesaModel?> getMesaById(String id) async {
    final row = await _db.getMesaById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Stream<List<MesaModel>> watchMesas() =>
      _db.watchAllMesas().map((rows) => rows.map(_toModel).toList());

  @override
  Future<void> upsert(MesaModel mesa, {required bool dirty}) {
    return _db.upsertMesa(MesasCompanion.insert(
      id: mesa.id,
      name: mesa.name,
      description: Value(mesa.description),
      createdBy: mesa.createdBy,
      createdAt: Value(mesa.createdAt),
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isDirty(String id) async =>
      (await _db.getMesaById(id))?.dirty ?? false;

  @override
  Future<void> markSynced(String id) => _db.clearMesaDirty(id);

  @override
  Future<void> softDelete(String id) => _db.softDeleteMesa(id);

  @override
  Future<void> hardDelete(String id) => _db.hardDeleteMesa(id);

  @override
  Future<void> restore(String id) => _db.restoreMesa(id);
}
