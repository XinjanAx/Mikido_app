import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/player_model.dart';

abstract class PlayerLocalDataSource {
  Future<List<PlayerModel>> getPlayers();
  Stream<List<PlayerModel>> watchPlayers();
  Future<PlayerModel?> getPlayerById(String id);
  Future<void> upsertPlayer(PlayerModel player, {required bool dirty});
  Future<bool> isPlayerDirty(String id);
  Future<void> markPlayerSynced(String id);
  Future<void> softDeletePlayer(String id);
  Future<void> hardDeletePlayer(String id);

  Future<List<PlayerModel>> getPlayersByTournament(String tournamentId);

  /// [id] sintético `'tournamentId:playerId'`.
  Future<void> upsertEnrollment({
    required String id,
    required String tournamentId,
    required String playerId,
    required bool dirty,
  });
  Future<bool> isEnrollmentDirty(String id);
  Future<void> markEnrollmentSynced(String id);
  Future<void> softDeleteEnrollment(String id);
  Future<void> hardDeleteEnrollment(String id);
  Future<List<({String id, String tournamentId, String playerId})>>
      getAllEnrollments();
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  final AppDatabase _db;
  const PlayerLocalDataSourceImpl(this._db);

  static String enrollmentId(String tournamentId, String playerId) =>
      '$tournamentId:$playerId';

  PlayerModel _toModel(Player row) => PlayerModel(
        id: row.id,
        name: row.name,
        email: row.email,
        phone: row.phone,
        birthDate: row.birthDate,
        photoUrl: row.photoUrl,
        createdAt: row.createdAt,
      );

  @override
  Future<List<PlayerModel>> getPlayers() async =>
      (await _db.getAllPlayersLocal()).map((r) => _toModel(r)).toList();

  @override
  Stream<List<PlayerModel>> watchPlayers() => _db
      .watchAllPlayersLocal()
      .map((rows) => rows.map((r) => _toModel(r)).toList());

  @override
  Future<PlayerModel?> getPlayerById(String id) async {
    final row = await _db.getPlayerById(id);
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> upsertPlayer(PlayerModel player, {required bool dirty}) {
    return _db.upsertPlayer(PlayersCompanion.insert(
      id: player.id,
      name: player.name,
      email: Value(player.email),
      phone: Value(player.phone),
      birthDate: Value(player.birthDate),
      photoUrl: Value(player.photoUrl),
      createdAt: Value(player.createdAt),
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isPlayerDirty(String id) async {
    final row = await _db.getPlayerById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markPlayerSynced(String id) => _db.clearPlayerDirty(id);

  @override
  Future<void> softDeletePlayer(String id) => _db.softDeletePlayer(id);

  @override
  Future<void> hardDeletePlayer(String id) => _db.hardDeletePlayer(id);

  @override
  Future<List<PlayerModel>> getPlayersByTournament(String tournamentId) async {
    final rows = await _db.getPlayersWithEnrollmentByTournament(tournamentId);
    return rows.map((r) => _toModel(r.$1)).toList();
  }

  @override
  Future<void> upsertEnrollment({
    required String id,
    required String tournamentId,
    required String playerId,
    required bool dirty,
  }) {
    return _db.upsertEnrollment(EnrollmentsCompanion.insert(
      id: id,
      tournamentId: tournamentId,
      playerId: playerId,
      dirty: Value(dirty),
    ));
  }

  @override
  Future<bool> isEnrollmentDirty(String id) async {
    final row = await _db.getEnrollmentById(id);
    return row?.dirty ?? false;
  }

  @override
  Future<void> markEnrollmentSynced(String id) =>
      _db.clearEnrollmentDirty(id);

  @override
  Future<void> softDeleteEnrollment(String id) =>
      _db.softDeleteEnrollment(id);

  @override
  Future<void> hardDeleteEnrollment(String id) =>
      _db.hardDeleteEnrollment(id);

  @override
  Future<List<({String id, String tournamentId, String playerId})>>
      getAllEnrollments() async {
    final rows = await _db.getAllEnrollmentsLocal();
    return rows
        .map((r) => (
              id: r.id,
              tournamentId: r.tournamentId,
              playerId: r.playerId,
            ))
        .toList();
  }
}
