import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show fixtureLocalDataSourceProvider;
import '../../data/datasources/standing_local_datasource.dart';
import '../../data/datasources/standing_remote_datasource.dart';
import '../../data/repositories/standing_repository_impl.dart';
import '../../data/services/standings_recalculation_service.dart';
import '../../data/sync/standing_sync_adapter.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/repositories/standing_repository.dart';
import '../../domain/usecases/standing_usecases.dart';

final standingRemoteDataSourceProvider = Provider<StandingRemoteDataSource>(
  (ref) => StandingRemoteDataSourceImpl(Supabase.instance.client),
);

final standingLocalDataSourceProvider = Provider<StandingLocalDataSource>(
  (ref) => StandingLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final standingSyncAdapterProvider = Provider<StandingSyncAdapter>(
  (ref) => StandingSyncAdapter(
    ref.watch(standingRemoteDataSourceProvider),
    ref.watch(standingLocalDataSourceProvider),
  ),
);

final standingsRecalculationServiceProvider =
    Provider<StandingsRecalculationService>(
  (ref) => StandingsRecalculationService(
    ref.watch(fixtureLocalDataSourceProvider),
    ref.watch(standingLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final standingRepositoryProvider = Provider<StandingRepository>(
  (ref) => StandingRepositoryImpl(
    ref.watch(standingLocalDataSourceProvider),
    ref.watch(standingsRecalculationServiceProvider),
    ref.watch(syncEngineProvider),
  ),
);

final getStandingsUseCaseProvider = Provider(
  (ref) => GetStandingsUseCase(ref.watch(standingRepositoryProvider)),
);
final recalculateStandingsUseCaseProvider = Provider(
  (ref) => RecalculateStandingsUseCase(ref.watch(standingRepositoryProvider)),
);

// Stream en tiempo real — clave para el requisito de actualización automática
final standingsStreamProvider =
    StreamProvider.family<List<StandingEntity>, String>((ref, tournamentId) {
  final repo = ref.watch(standingRepositoryProvider);
  return repo.watchStandings(tournamentId);
});

// Posiciones como Future (para carga inicial)
final standingsFutureProvider =
    FutureProvider.family<List<StandingEntity>, String>((ref, tournamentId) async {
  final useCase = ref.watch(getStandingsUseCaseProvider);
  final result = await useCase(tournamentId);
  return result.fold((_) => [], (list) => list);
});
