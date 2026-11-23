import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/tournament_model.dart';

abstract class TournamentLocalDataSource {
  Future<List<TournamentModel>> getTournaments();
  Future<TournamentModel?> getTournamentById(String id);
  Stream<List<TournamentModel>> watchTournaments();

  /// Inserta o actualiza la fila local. [dirty] indica si el cambio se
  /// originó localmente (pendiente de subir) o viene de un pull remoto.
  Future<void> upsert(TournamentModel tournament, {required bool dirty});
  Future<bool> isDirty(String id);
  Future<void> markSynced(String id);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
}

class TournamentLocalDataSourceImpl implements TournamentLocalDataSource {
  final AppDatabase _db;
  const TournamentLocalDataSourceImpl(this._db);

  TournamentModel _toModel(Tournament row) => TournamentModel(
        id: row.id,
        name: row.name,
        mode: row.mode,
        status: row.status,
        description: row.description,
        startDate: row.startDate,
        endDate: row.endDate,
        createdBy: row.createdBy,
        createdAt: row.createdAt,
        mesaId: row.mesaId,
        color: row.color,
      );

  @override
  Future<List<TournamentModel>> getTournaments() async =>
      (await _db.getAllTournaments()).map(_toModel).toList();

  @override
  Future<TournamentModel?> getTournamentById(String id) async {
    final row = await _db.getTournamentById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Stream<List<TournamentModel>> watchTournaments() =>
      _db.watchAllTournaments().map((rows) => rows.map(_toModel).toList());

  @override
  Future<void> upsert(TournamentModel tournament, {required bool dirty}) {
    return _db.upsertTournament(TournamentsCompanion.insert(
      id: tournament.id,
      name: tournament.name,
      mode: tournament.mode,
      status: tournament.status,
      description: Value(tournament.description),
      startDate: tournament.startDate,
      endDate: tournament.endDate,
      createdBy: tournament.createdBy,
      createdAt: Value(tournament.createdAt),
      mesaId: Value(tournament.mesaId),
      color: Value(tournament.color),
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isDirty(String id) async {
    final row = await _db.getTournamentById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markSynced(String id) => _db.clearTournamentDirty(id);

  @override
  Future<void> softDelete(String id) => _db.softDeleteTournament(id);

  @override
  Future<void> hardDelete(String id) => _db.hardDeleteTournament(id);
}
