import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../standings/presentation/providers/standing_provider.dart'
    show standingsRecalculationServiceProvider;
import '../../../tournaments/presentation/providers/tournament_provider.dart'
    show tournamentLocalDataSourceProvider;
import '../../data/datasources/fixture_local_datasource.dart';
import '../../data/datasources/fixture_remote_datasource.dart';
import '../../data/repositories/fixture_repository_impl.dart';
import '../../data/services/elimination_bracket_service.dart';
import '../../data/services/match_result_service.dart';
import '../../data/sync/fixture_sync_adapter.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../../domain/usecases/fixture_usecases.dart';

final fixtureRemoteDataSourceProvider = Provider<FixtureRemoteDataSource>(
  (ref) => FixtureRemoteDataSourceImpl(Supabase.instance.client),
);

final fixtureLocalDataSourceProvider = Provider<FixtureLocalDataSource>(
  (ref) => FixtureLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final fixtureSyncAdapterProvider = Provider<FixtureSyncAdapter>(
  (ref) => FixtureSyncAdapter(
    ref.watch(fixtureRemoteDataSourceProvider),
    ref.watch(fixtureLocalDataSourceProvider),
  ),
);

final eliminationBracketServiceProvider = Provider<EliminationBracketService>(
  (ref) => EliminationBracketService(
    ref.watch(fixtureLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final matchResultServiceProvider = Provider<MatchResultService>(
  (ref) => MatchResultService(
    ref.watch(fixtureLocalDataSourceProvider),
    ref.watch(tournamentLocalDataSourceProvider),
    ref.watch(standingsRecalculationServiceProvider),
    ref.watch(eliminationBracketServiceProvider),
    ref.watch(appDatabaseProvider),
  ),
);

final fixtureRepositoryProvider = Provider<FixtureRepository>(
  (ref) => FixtureRepositoryImpl(
    ref.watch(fixtureLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
    ref.watch(matchResultServiceProvider),
  ),
);

final getMatchesUseCaseProvider = Provider(
  (ref) => GetMatchesUseCase(ref.watch(fixtureRepositoryProvider)),
);
final generateFixtureUseCaseProvider = Provider(
  (ref) => GenerateFixtureUseCase(ref.watch(fixtureRepositoryProvider)),
);
final updateMatchResultUseCaseProvider = Provider(
  (ref) => UpdateMatchResultUseCase(ref.watch(fixtureRepositoryProvider)),
);
final deleteFixtureUseCaseProvider = Provider(
  (ref) => DeleteFixtureUseCase(ref.watch(fixtureRepositoryProvider)),
);

// ---------- State ----------

class FixtureState {
  final List<MatchEntity> matches;
  final bool isLoading;
  final bool isGenerating;
  final String? errorMessage;

  const FixtureState({
    this.matches = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.errorMessage,
  });

  FixtureState copyWith({
    List<MatchEntity>? matches,
    bool? isLoading,
    bool? isGenerating,
    String? errorMessage,
  }) =>
      FixtureState(
        matches: matches ?? this.matches,
        isLoading: isLoading ?? this.isLoading,
        isGenerating: isGenerating ?? this.isGenerating,
        errorMessage: errorMessage,
      );

  Map<String, List<MatchEntity>> get matchesByRound {
    final map = <String, List<MatchEntity>>{};
    for (final m in matches) {
      final round = m.round ?? 'Sin ronda';
      map.putIfAbsent(round, () => []).add(m);
    }
    return map;
  }
}

class FixtureNotifier extends StateNotifier<FixtureState> {
  final GetMatchesUseCase _getMatches;
  final GenerateFixtureUseCase _generate;
  final UpdateMatchResultUseCase _updateResult;
  final DeleteFixtureUseCase _deleteFixture;
  final String tournamentId;

  FixtureNotifier({
    required GetMatchesUseCase getMatches,
    required GenerateFixtureUseCase generate,
    required UpdateMatchResultUseCase updateResult,
    required DeleteFixtureUseCase deleteFixture,
    required this.tournamentId,
  })  : _getMatches = getMatches,
        _generate = generate,
        _updateResult = updateResult,
        _deleteFixture = deleteFixture,
        super(const FixtureState()) {
    loadMatches();
  }

  Future<void> loadMatches({String? categoryId}) async {
    state = state.copyWith(isLoading: true);
    final result = await _getMatches(tournamentId, categoryId: categoryId);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (list) => state = state.copyWith(isLoading: false, matches: list),
    );
  }

  Future<bool> generateFixture({
    required String categoryId,
    required String mode,
    required List<String> playerIds,
    required List<String> playerNames,
    int timesPlayed = 1,
    int numberOfGroups = 0,
    List<List<String>>? manualGroups,
    List<String>? manualBracketOrder,
  }) async {
    state = state.copyWith(isGenerating: true);
    final result = await _generate(
      tournamentId: tournamentId,
      categoryId: categoryId,
      mode: mode,
      playerIds: playerIds,
      playerNames: playerNames,
      timesPlayed: timesPlayed,
      numberOfGroups: numberOfGroups,
      manualGroups: manualGroups,
      manualBracketOrder: manualBracketOrder,
    );
    return result.fold(
      (f) {
        state = state.copyWith(isGenerating: false, errorMessage: f.message);
        return false;
      },
      (newMatches) {
        // Mantener partidos de otras categorías y agregar los nuevos
        final otherMatches =
            state.matches.where((m) => m.categoryId != categoryId).toList();
        state = state.copyWith(
          isGenerating: false,
          matches: [...otherMatches, ...newMatches],
        );
        return true;
      },
    );
  }

  Future<bool> updateResult({
    required String matchId,
    required int homeScore,
    required int awayScore,
  }) async {
    final result = await _updateResult(
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
    );
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (updated) async {
        // Recargar TODOS los partidos para incluir nuevas rondas
        await loadMatches();
        return true;
      },
    );
  }

  Future<bool> deleteFixture() async {
    final result = await _deleteFixture(tournamentId);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(matches: []);
        return true;
      },
    );
  }
}

final fixtureProvider =
    StateNotifierProvider.family<FixtureNotifier, FixtureState, String>(
  (ref, tournamentId) => FixtureNotifier(
    getMatches: ref.watch(getMatchesUseCaseProvider),
    generate: ref.watch(generateFixtureUseCaseProvider),
    updateResult: ref.watch(updateMatchResultUseCaseProvider),
    deleteFixture: ref.watch(deleteFixtureUseCaseProvider),
    tournamentId: tournamentId,
  ),
);

// Stream en tiempo real de partidos
final matchesStreamProvider =
    StreamProvider.family<List<MatchEntity>, String>((ref, tournamentId) {
  final repo = ref.watch(fixtureRepositoryProvider);
  return repo.watchMatches(tournamentId);
});
