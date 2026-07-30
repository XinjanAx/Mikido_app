import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../datasources/player_local_datasource.dart';
import '../datasources/player_remote_datasource.dart';

class EnrollmentSyncAdapter implements SyncAdapter {
  final PlayerRemoteDataSource _remote;
  final PlayerLocalDataSource _local;

  const EnrollmentSyncAdapter(this._remote, this._local);

  @override
  String get tableName => SupabaseConstants.enrollmentsTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.enrollPlayer(
      playerId: payload['player_id'] as String,
      tournamentId: payload['tournament_id'] as String,
    );
  }

  @override
  Future<void> pushDelete(String rowId) async {
    // rowId sintético: 'tournamentId:playerId'.
    final parts = rowId.split(':');
    await _remote.unenrollPlayer(tournamentId: parts[0], playerId: parts[1]);
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    if (wasDelete) {
      await _local.hardDeleteEnrollment(rowId);
    } else {
      await _local.markEnrollmentSynced(rowId);
    }
  }

  @override
  Future<void> pull() async {
    // Solo agrega/actualiza desde lo remoto — nunca borra localmente por
    // "no aparece en esta traída" (una traída vacía o parcial por
    // timing/red inestable borraba inscripciones reales sin excepción ni
    // aviso, y no se recuperaban solas). Ver mismo comentario en
    // TournamentSyncAdapter.pull().
    final remoteRows = await _remote.getAllEnrollments();
    for (final row in remoteRows) {
      final tournamentId = row['tournament_id'] as String;
      final playerId = row['player_id'] as String;
      final id = '$tournamentId:$playerId';

      if (await _local.isEnrollmentDirty(id)) continue;
      await _local.upsertEnrollment(
        id: id,
        tournamentId: tournamentId,
        playerId: playerId,
        dirty: false,
      );
    }
  }
}
