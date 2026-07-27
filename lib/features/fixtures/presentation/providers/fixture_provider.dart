import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/fixture_remote_datasource.dart';
import '../../data/repositories/fixture_repository_impl.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/fixture_repository.dart';
import '../../domain/usecases/fixture_usecases.dart';

final fixtureRemoteDataSourceProvider = Provider<FixtureRemoteDataSource>(
  (ref) => FixtureRemoteDataSourceImpl(Supabase.instance.client),
);
final fixtureRepositoryProvider = Provider<FixtureRepository>(
  (ref) => FixtureRepositoryImpl(ref.watch(fixtureRemoteDataSourceProvider)),
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
  final String tournamentId;

  FixtureNotifier({
    required GetMatchesUseCase getMatches,
    required GenerateFixtureUseCase generate,
    required UpdateMatchResultUseCase updateResult,
    required this.tournamentId,
  })  : _getMatches = getMatches,
        _generate = generate,
        _updateResult = updateResult,
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
  }) async {
    state = state.copyWith(isGenerating: true);
    final result = await _generate(
      tournamentId: tournamentId,
      categoryId: categoryId,
      mode: mode,
      playerIds: playerIds,
      playerNames: playerNames,
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
      (updated) {
        state = state.copyWith(
          matches: state.matches
              .map((m) => m.id == updated.id ? updated : m)
              .toList(),
        );
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
    tournamentId: tournamentId,
  ),
);

// Stream en tiempo real de partidos
final matchesStreamProvider =
    StreamProvider.family<List<MatchEntity>, String>((ref, tournamentId) {
  final repo = ref.watch(fixtureRepositoryProvider);
  return repo.watchMatches(tournamentId);
});
