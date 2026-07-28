import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/standing_model.dart';

abstract class StandingLocalDataSource {
  Future<List<StandingModel>> getStandings(String tournamentId,
      {String? categoryId});
  Future<List<StandingModel>> getAllStandings();
  Stream<List<StandingModel>> watchStandings(String tournamentId);

  Future<void> upsert(StandingModel standing, {required bool dirty});
  Future<bool> isDirty(String id);
  Future<void> markSynced(String id);
}

class StandingLocalDataSourceImpl implements StandingLocalDataSource {
  final AppDatabase _db;
  const StandingLocalDataSourceImpl(this._db);

  StandingModel _toModel(Standing row) => StandingModel(
        id: row.id,
        tournamentId: row.tournamentId,
        categoryId: row.categoryId,
        playerId: row.playerId,
        playerName: row.playerName,
        played: row.played,
        won: row.won,
        drawn: row.drawn,
        lost: row.lost,
        goalsFor: row.goalsFor,
        goalsAgainst: row.goalsAgainst,
        points: row.points,
      );

  @override
  Future<List<StandingModel>> getStandings(String tournamentId,
          {String? categoryId}) async =>
      (await _db.getStandingsByTournament(tournamentId, categoryId: categoryId))
          .map(_toModel)
          .toList();

  @override
  Future<List<StandingModel>> getAllStandings() async =>
      (await _db.getAllStandingsLocal()).map(_toModel).toList();

  @override
  Stream<List<StandingModel>> watchStandings(String tournamentId) =>
      _db.watchStandings(tournamentId).map((rows) => rows.map(_toModel).toList());

  @override
  Future<void> upsert(StandingModel standing, {required bool dirty}) {
    return _db.upsertStanding(StandingsCompanion.insert(
      id: standing.id,
      tournamentId: standing.tournamentId,
      categoryId: standing.categoryId,
      playerId: standing.playerId,
      playerName: standing.playerName,
      played: Value(standing.played),
      won: Value(standing.won),
      drawn: Value(standing.drawn),
      lost: Value(standing.lost),
      goalsFor: Value(standing.goalsFor),
      goalsAgainst: Value(standing.goalsAgainst),
      points: Value(standing.points),
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isDirty(String id) async {
    final row = await _db.getStandingById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markSynced(String id) => _db.clearStandingDirty(id);
}
