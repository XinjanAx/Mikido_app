import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/sync/sync_adapter.dart';
import '../../../tournaments/data/datasources/tournament_local_datasource.dart';
import '../datasources/fixture_local_datasource.dart';
import '../datasources/fixture_remote_datasource.dart';
import '../models/match_model.dart';
import '../services/elimination_bracket_service.dart';

class FixtureSyncAdapter implements SyncAdapter {
  final FixtureRemoteDataSource _remote;
  final FixtureLocalDataSource _local;
  final EliminationBracketService _bracket;
  final TournamentLocalDataSource _tournaments;

  const FixtureSyncAdapter(
    this._remote,
    this._local,
    this._bracket,
    this._tournaments,
  );

  @override
  String get tableName => SupabaseConstants.matchesTable;

  @override
  Future<void> pushUpsert(Map<String, dynamic> payload) async {
    await _remote.upsertMatch(MatchModel.fromJson(payload));
  }

  @override
  Future<void> pushDelete(String rowId) async {
    await _remote.deleteMatch(rowId);
  }

  @override
  Future<void> markSynced(String rowId, {required bool wasDelete}) async {
    if (wasDelete) {
      await _local.hardDelete(rowId);
    } else {
      await _local.markSynced(rowId);
    }
  }

  @override
  Future<void> pull() async {
    // Solo agrega/actualiza desde lo remoto — nunca borra localmente por
    // "no aparece en esta traída" (una traída vacía o parcial por
    // timing/red inestable borraba partidos reales sin excepción ni
    // aviso, y no se recuperaban solos). Ver mismo comentario en
    // TournamentSyncAdapter.pull().
    final remoteList = await _remote.getAllMatches();
    for (final m in remoteList) {
      if (await _local.isDirty(m.id)) continue;
      await _local.upsert(m, dirty: false);
    }

    await _advanceEliminationBrackets(remoteList);
  }

  /// `advance()` también se llama al guardar un resultado localmente
  /// (ver MatchResultService), pero ese dispositivo solo ve sus propios
  /// partidos: si dos admins juegan rondas distintas del mismo cuadro en
  /// dispositivos distintos, ninguno de los dos observa nunca "toda la
  /// ronda terminada" en el momento de guardar. Al traer los resultados
  /// del otro dispositivo por sync, reintentamos avanzar aquí — así la
  /// ronda no se queda atascada esperando a que alguien vuelva a tocar
  /// un resultado de esa ronda.
  Future<void> _advanceEliminationBrackets(List<MatchModel> remoteList) async {
    final roundsByTournament = <String, Set<String>>{};
    for (final m in remoteList) {
      final round = m.round;
      if (round == null) continue;
      roundsByTournament.putIfAbsent(m.tournamentId, () => {}).add(round);
    }

    for (final entry in roundsByTournament.entries) {
      final tournament = await _tournaments.getTournamentById(entry.key);
      if (tournament?.mode != AppConstants.tournamentModeElimination) continue;
      for (final round in entry.value) {
        try {
          await _bracket.advance(tournamentId: entry.key, completedRound: round);
        } catch (_) {
          // No interrumpir el resto de la sincronización.
        }
      }
    }
  }
}
