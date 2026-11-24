import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show fixtureLocalDataSourceProvider;
import '../../../tournaments/domain/entities/tournament_entity.dart';
import '../../../tournaments/presentation/providers/tournament_provider.dart'
    show tournamentsProvider;
import '../../data/datasources/mesa_local_datasource.dart';
import '../../data/datasources/mesa_remote_datasource.dart';
import '../../data/repositories/mesa_repository.dart';
import '../../data/services/mesa_schedule_service.dart';
import '../../data/sync/mesa_sync_adapter.dart';
import '../../domain/entities/mesa_entity.dart';
import '../../domain/services/mesa_progress.dart';

// ---------- Infraestructura ----------

final mesaRemoteDataSourceProvider = Provider<MesaRemoteDataSource>(
  (ref) => MesaRemoteDataSourceImpl(Supabase.instance.client),
);

final mesaLocalDataSourceProvider = Provider<MesaLocalDataSource>(
  (ref) => MesaLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final mesaSyncAdapterProvider = Provider<MesaSyncAdapter>(
  (ref) => MesaSyncAdapter(
    ref.watch(mesaRemoteDataSourceProvider),
    ref.watch(mesaLocalDataSourceProvider),
  ),
);

final mesaScheduleServiceProvider = Provider<MesaScheduleService>(
  (ref) => MesaScheduleService(
    ref.watch(fixtureLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final mesaRepositoryProvider = Provider<MesaRepository>(
  (ref) => MesaRepository(
    ref.watch(mesaLocalDataSourceProvider),
    ref.watch(mesaRemoteDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  ),
);

// ---------- Estado ----------

/// Lista de mesas, siempre al día desde la base local.
final mesasProvider = StreamProvider<List<MesaEntity>>(
  (ref) => ref.watch(mesaRepositoryProvider).watchMesas(),
);

final mesaByIdProvider = Provider.family<MesaEntity?, String>((ref, id) {
  final mesas = ref.watch(mesasProvider).valueOrNull ?? const [];
  for (final m in mesas) {
    if (m.id == id) return m;
  }
  return null;
});

/// Categorías de una mesa. Con `null` devuelve las categorías sin mesa
/// (datos anteriores a la v6 que todavía no se asignaron).
final categoriesByMesaProvider =
    Provider.family<List<TournamentEntity>, String?>((ref, mesaId) {
  return ref
      .watch(tournamentsProvider)
      .tournaments
      .where((t) => t.mesaId == mesaId)
      .toList();
});

/// Cola de la mesa: todos los encuentros con turno, en orden.
final mesaQueueProvider =
    StreamProvider.family<List<MatchEntity>, String>((ref, mesaId) {
  return ref
      .watch(fixtureLocalDataSourceProvider)
      .watchMatchesByMesa(mesaId)
      .map((list) => list.where((m) => m.mesaOrder != null).toList()
        ..sort((a, b) => a.mesaOrder!.compareTo(b.mesaOrder!)));
});

/// Total final de encuentros de la mesa para el contador "X de Y": en
/// eliminación incluye las rondas que todavía no se generan (y el 3er
/// puesto). Ver [MesaProgress.projectedTotal].
final mesaProjectedTotalProvider = Provider.family<int, String>((ref, mesaId) {
  final all = ref
          .watch(_mesaAllMatchesProvider(mesaId))
          .valueOrNull ??
      const <MatchEntity>[];
  final tournaments = ref.watch(tournamentsProvider).tournaments;
  final modes = {for (final t in tournaments) t.id: t.mode};
  return MesaProgress.projectedTotal(all, (id) => modes[id]);
});

/// Todos los encuentros de la mesa, incluidos los BYE (sin turno).
final _mesaAllMatchesProvider =
    StreamProvider.family<List<MatchEntity>, String>((ref, mesaId) {
  return ref.watch(fixtureLocalDataSourceProvider).watchMatchesByMesa(mesaId);
});

class MesaActions {
  final MesaRepository _repository;
  final String _userId;

  const MesaActions(this._repository, this._userId);

  Future<void> create({required String name, String? description}) {
    return _repository.save(MesaEntity(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdBy: _userId,
    ));
  }

  Future<void> update(MesaEntity mesa,
      {required String name, String? description}) {
    return _repository.save(MesaEntity(
      id: mesa.id,
      name: name,
      description: description,
      createdBy: mesa.createdBy,
      createdAt: mesa.createdAt,
    ));
  }

  Future<bool> delete(String id) => _repository.delete(id);
}

final mesaActionsProvider = Provider<MesaActions>(
  (ref) => MesaActions(
    ref.watch(mesaRepositoryProvider),
    ref.watch(currentUserProvider)?.id ?? '',
  ),
);
