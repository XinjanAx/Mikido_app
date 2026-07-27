import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/standing_remote_datasource.dart';
import '../../data/repositories/standing_repository_impl.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/repositories/standing_repository.dart';
import '../../domain/usecases/standing_usecases.dart';

final standingRemoteDataSourceProvider = Provider<StandingRemoteDataSource>(
  (ref) => StandingRemoteDataSourceImpl(Supabase.instance.client),
);
final standingRepositoryProvider = Provider<StandingRepository>(
  (ref) => StandingRepositoryImpl(ref.watch(standingRemoteDataSourceProvider)),
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
