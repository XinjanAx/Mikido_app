import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../fixtures/data/datasources/fixture_local_datasource.dart';
import '../../../fixtures/data/models/match_model.dart';
import '../../domain/services/mesa_scheduler.dart';

/// Asigna el turno global (`mesaOrder`) de los encuentros dentro de su mesa,
/// usando [MesaScheduler] (lógica pura) y guardando el resultado en la base
/// local + outbox, como el resto de la app.
///
/// Se llama desde tres lugares:
/// - al generar el fixture de una categoría → [placeNewCategoryMatches];
/// - al generar una ronda nueva de eliminación → [placeNewRoundMatches];
/// - al borrar encuentros o una categoría → [compact].
class MesaScheduleService {
  final FixtureLocalDataSource _matches;
  final AppDatabase _db;

  const MesaScheduleService(this._matches, this._db);

  /// Fixture recién generado de una categoría. Devuelve [newMatches] con su
  /// turno asignado (el caller los guarda) y guarda él mismo los corrimientos
  /// de los encuentros que ya estaban en la cola.
  Future<List<MatchModel>> placeNewCategoryMatches(
    String tournamentId,
    List<MatchModel> newMatches,
  ) {
    return _place(
        tournamentId,
        newMatches,
        (queue, items) =>
            MesaScheduler.interleave(queue: queue, newItems: items));
  }

  /// Ronda nueva de eliminación de una categoría que ya está en juego. El
  /// 3er puesto se ubica antes de la Final.
  Future<List<MatchModel>> placeNewRoundMatches(
    String tournamentId,
    List<MatchModel> newMatches,
  ) {
    int rank(MatchModel m) => m.round == 'Tercer puesto' ? 0 : 1;
    final ordered = [...newMatches]..sort((a, b) {
        final r = rank(a).compareTo(rank(b));
        return r != 0 ? r : (a.matchNumber ?? 0).compareTo(b.matchNumber ?? 0);
      });
    return _place(
        tournamentId,
        ordered,
        (queue, items) =>
            MesaScheduler.insertEarliest(queue: queue, newItems: items));
  }

  /// Renumera la cola de la mesa sin huecos (1, 2, 3...) manteniendo el
  /// orden actual — después de borrar encuentros o una categoría.
  Future<void> compact(String? mesaId) async {
    if (mesaId == null) return;
    final all = await _matches.getMatchesByMesa(mesaId);
    final queue = _sortedQueue(all.where((m) => !m.isBye));
    await _persistChanges(all, {
      for (var i = 0; i < queue.length; i++) queue[i].id: i + 1,
    });
  }

  /// Mesa de una categoría (null en datos viejos sin mesa asignada).
  Future<String?> mesaIdOf(String tournamentId) async =>
      (await _db.getTournamentById(tournamentId))?.mesaId;

  // ---------------------------------------------------------------------

  Future<List<MatchModel>> _place(
    String tournamentId,
    List<MatchModel> newMatches,
    List<ScheduleItem> Function(List<ScheduleItem>, List<ScheduleItem>) plan,
  ) async {
    final mesaId = await mesaIdOf(tournamentId);
    if (mesaId == null) return newMatches;

    final newIds = newMatches.map((m) => m.id).toSet();
    final existing = (await _matches.getMatchesByMesa(mesaId))
        .where((m) => !newIds.contains(m.id))
        .toList();

    final queue = _sortedQueue(existing.where((m) => !m.isBye));
    final items = newMatches.where((m) => !m.isBye).map(_toItem).toList();
    final ordered = plan(queue.map(_toItem).toList(), items);

    final orders = <String, int>{
      for (var i = 0; i < ordered.length; i++) ordered[i].id: i + 1,
    };
    await _persistChanges(existing, orders);

    return [
      for (final m in newMatches)
        m.withMesaOrder(m.isBye ? null : orders[m.id]),
    ];
  }

  /// Cola actual ordenada por turno. Los que no tienen turno (datos viejos)
  /// van al final, en orden de categoría y número de encuentro.
  List<MatchModel> _sortedQueue(Iterable<MatchModel> matches) {
    return matches.toList()
      ..sort((a, b) {
        final oa = a.mesaOrder ?? 1 << 30;
        final ob = b.mesaOrder ?? 1 << 30;
        if (oa != ob) return oa.compareTo(ob);
        final t = a.tournamentId.compareTo(b.tournamentId);
        if (t != 0) return t;
        return (a.matchNumber ?? 0).compareTo(b.matchNumber ?? 0);
      });
  }

  ScheduleItem _toItem(MatchModel m) => ScheduleItem(
        id: m.id,
        tournamentId: m.tournamentId,
        round: m.round,
        homePlayerId: m.homePlayerId,
        awayPlayerId: m.awayPlayerId,
        isPlayed: m.status != AppConstants.matchStatusPending,
      );

  /// Guarda y encola solo los encuentros cuyo turno cambió. Los que no
  /// aparecen en [orders] (los BYE) quedan sin turno.
  Future<void> _persistChanges(
      List<MatchModel> matches, Map<String, int> orders) async {
    for (final m in matches) {
      final newOrder = orders[m.id];
      if (m.mesaOrder == newOrder) continue;
      final updated = m.withMesaOrder(newOrder);
      await _matches.upsert(updated, dirty: true);
      await _db.enqueueUpsert(
          SupabaseConstants.matchesTable, updated.id, updated.toJson());
    }
  }
}
