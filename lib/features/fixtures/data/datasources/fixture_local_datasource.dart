import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/match_model.dart';

abstract class FixtureLocalDataSource {
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId);
  Future<MatchModel?> getMatchById(String id);
  Future<List<MatchModel>> getMatchesByRound(String tournamentId, String round);
  Future<List<MatchModel>> getAllMatches();
  Stream<List<MatchModel>> watchMatches(String tournamentId);

  Future<void> upsert(MatchModel match, {required bool dirty});
  Future<bool> isDirty(String id);
  Future<void> markSynced(String id);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
}

class FixtureLocalDataSourceImpl implements FixtureLocalDataSource {
  final AppDatabase _db;
  const FixtureLocalDataSourceImpl(this._db);

  MatchModel _toModel(MatchRow row) => MatchModel(
        id: row.id,
        tournamentId: row.tournamentId,
        homePlayerId: row.homePlayerId,
        awayPlayerId: row.awayPlayerId,
        homePlayerName: row.homePlayerName,
        awayPlayerName: row.awayPlayerName,
        homeScore: row.homeScore,
        awayScore: row.awayScore,
        status: row.status,
        scheduledAt: row.scheduledAt,
        round: row.round,
        matchNumber: row.matchNumber,
        createdAt: row.createdAt,
      );

  @override
  Future<List<MatchModel>> getMatchesByTournament(String tournamentId) async =>
      (await _db.getMatchesByTournament(tournamentId)).map(_toModel).toList();

  @override
  Future<MatchModel?> getMatchById(String id) async {
    final row = await _db.getMatchById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<MatchModel>> getMatchesByRound(
          String tournamentId, String round) async =>
      (await _db.getMatchesByRound(tournamentId, round))
          .map(_toModel)
          .toList();

  @override
  Future<List<MatchModel>> getAllMatches() async =>
      (await _db.getAllMatchesLocal()).map(_toModel).toList();

  @override
  Stream<List<MatchModel>> watchMatches(String tournamentId) =>
      _db.watchMatches(tournamentId).map((rows) => rows.map(_toModel).toList());

  @override
  Future<void> upsert(MatchModel match, {required bool dirty}) {
    return _db.upsertMatch(MatchesCompanion.insert(
      id: match.id,
      tournamentId: match.tournamentId,
      homePlayerId: match.homePlayerId,
      awayPlayerId: match.awayPlayerId,
      homePlayerName: match.homePlayerName,
      awayPlayerName: match.awayPlayerName,
      homeScore: Value(match.homeScore),
      awayScore: Value(match.awayScore),
      status: match.status,
      scheduledAt: Value(match.scheduledAt),
      round: Value(match.round),
      matchNumber: Value(match.matchNumber),
      createdAt: Value(match.createdAt),
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isDirty(String id) async {
    final row = await _db.getMatchById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markSynced(String id) => _db.clearMatchDirty(id);

  @override
  Future<void> softDelete(String id) => _db.softDeleteMatch(id);

  @override
  Future<void> hardDelete(String id) => _db.hardDeleteMatch(id);
}
