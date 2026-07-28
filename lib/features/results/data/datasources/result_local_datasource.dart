import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/result_model.dart';

abstract class ResultLocalDataSource {
  Future<List<ResultModel>> getResultsByTournament(String tournamentId);
  Future<ResultModel?> getResultByMatch(String matchId);
  Future<List<ResultModel>> getAllResults();

  Future<void> upsert(ResultModel result, {required bool dirty});
  Future<bool> isDirty(String id);
  Future<void> markSynced(String id);
}

class ResultLocalDataSourceImpl implements ResultLocalDataSource {
  final AppDatabase _db;
  const ResultLocalDataSourceImpl(this._db);

  ResultModel _toModel(Result row) => ResultModel(
        id: row.id,
        matchId: row.matchId,
        tournamentId: row.tournamentId,
        homePlayerId: row.homePlayerId,
        awayPlayerId: row.awayPlayerId,
        homeScore: row.homeScore,
        awayScore: row.awayScore,
        notes: row.notes,
        registeredBy: row.registeredBy,
        registeredAt: row.registeredAt,
      );

  @override
  Future<List<ResultModel>> getResultsByTournament(String tournamentId) async =>
      (await _db.getResultsByTournament(tournamentId)).map(_toModel).toList();

  @override
  Future<ResultModel?> getResultByMatch(String matchId) async {
    final row = await _db.getResultByMatch(matchId);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<ResultModel>> getAllResults() async =>
      (await _db.getAllResultsLocal()).map(_toModel).toList();

  @override
  Future<void> upsert(ResultModel result, {required bool dirty}) {
    return _db.upsertResult(ResultsCompanion.insert(
      id: result.id,
      matchId: result.matchId,
      tournamentId: result.tournamentId,
      homePlayerId: result.homePlayerId,
      awayPlayerId: result.awayPlayerId,
      homeScore: result.homeScore,
      awayScore: result.awayScore,
      notes: Value(result.notes),
      registeredBy: result.registeredBy,
      registeredAt: result.registeredAt,
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isDirty(String id) async {
    final row = await _db.getResultById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markSynced(String id) => _db.clearResultDirty(id);
}
