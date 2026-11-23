import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import 'sync_adapter.dart';
import 'sync_engine.dart';

// Cada feature offline-first agrega su adapter a esta lista al incorporarse.
import '../../features/fixtures/presentation/providers/fixture_provider.dart'
    show fixtureSyncAdapterProvider;
import '../../features/mesas/presentation/providers/mesa_provider.dart'
    show mesaSyncAdapterProvider;
import '../../features/players/presentation/providers/player_provider.dart'
    show enrollmentSyncAdapterProvider, playerSyncAdapterProvider;
import '../../features/results/presentation/providers/result_provider.dart'
    show resultSyncAdapterProvider;
import '../../features/standings/presentation/providers/standing_provider.dart'
    show standingSyncAdapterProvider;
import '../../features/tournaments/presentation/providers/tournament_provider.dart'
    show tournamentSyncAdapterProvider;

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final adapters = <SyncAdapter>[
    // Mesas antes que categorías: tournaments.mesa_id apunta a mesas.
    ref.watch(mesaSyncAdapterProvider),
    ref.watch(tournamentSyncAdapterProvider),
    ref.watch(playerSyncAdapterProvider),
    ref.watch(enrollmentSyncAdapterProvider),
    ref.watch(fixtureSyncAdapterProvider),
    ref.watch(resultSyncAdapterProvider),
    ref.watch(standingSyncAdapterProvider),
  ];
  return SyncEngine(db, adapters);
});
