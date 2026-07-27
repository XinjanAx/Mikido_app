import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/result_remote_datasource.dart';
import '../../data/repositories/result_repository_impl.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/result_repository.dart';
import '../../domain/usecases/register_result_usecase.dart';
import '../../domain/usecases/get_results_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Infrastructure
final resultRemoteDataSourceProvider = Provider<ResultRemoteDataSource>(
  (ref) => ResultRemoteDataSourceImpl(Supabase.instance.client),
);

final resultRepositoryProvider = Provider<ResultRepository>(
  (ref) =>
      ResultRepositoryImpl(ref.watch(resultRemoteDataSourceProvider)),
);

// Use cases
final registerResultUseCaseProvider = Provider(
  (ref) => RegisterResultUseCase(ref.watch(resultRepositoryProvider)),
);

final getResultsUseCaseProvider = Provider(
  (ref) => GetResultsUseCase(ref.watch(resultRepositoryProvider)),
);

final getResultByMatchUseCaseProvider = Provider(
  (ref) => GetResultByMatchUseCase(ref.watch(resultRepositoryProvider)),
);

// ---------- State ----------

class ResultState {
  final List<ResultEntity> results;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const ResultState({
    this.results = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  ResultState copyWith({
    List<ResultEntity>? results,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) =>
      ResultState(
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: errorMessage,
        successMessage: successMessage,
      );
}

class ResultNotifier extends StateNotifier<ResultState> {
  final RegisterResultUseCase _register;
  final GetResultsUseCase _getAll;
  final String _tournamentId;
  final String _userId;

  ResultNotifier({
    required RegisterResultUseCase register,
    required GetResultsUseCase getAll,
    required String tournamentId,
    required String userId,
  })  : _register = register,
        _getAll = getAll,
        _tournamentId = tournamentId,
        _userId = userId,
        super(const ResultState()) {
    loadResults();
  }

  Future<void> loadResults() async {
    state = state.copyWith(isLoading: true);
    final result = await _getAll(_tournamentId);
    result.fold(
      (f) => state =
          state.copyWith(isLoading: false, errorMessage: f.message),
      (list) => state = state.copyWith(isLoading: false, results: list),
    );
  }

  Future<bool> registerResult({
    required String matchId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    String? notes,
  }) async {
    state = state.copyWith(isSaving: true);

    final result = await _register(
      matchId: matchId,
      tournamentId: _tournamentId,
      homePlayerId: homePlayerId,
      awayPlayerId: awayPlayerId,
      homeScore: homeScore,
      awayScore: awayScore,
      registeredBy: _userId,
      notes: notes,
    );

    return result.fold(
      (f) {
        state = state.copyWith(
            isSaving: false, errorMessage: f.message);
        return false;
      },
      (registered) {
        // Agregar al inicio de la lista
        final updated = [registered, ...state.results];
        state = state.copyWith(
          isSaving: false,
          results: updated,
          successMessage: 'Resultado registrado correctamente',
        );
        return true;
      },
    );
  }
}

final resultProvider = StateNotifierProvider.family<ResultNotifier,
    ResultState, String>(
  (ref, tournamentId) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    return ResultNotifier(
      register: ref.watch(registerResultUseCaseProvider),
      getAll: ref.watch(getResultsUseCaseProvider),
      tournamentId: tournamentId,
      userId: userId,
    );
  },
);

// Resultado de un partido específico
final resultByMatchProvider =
    FutureProvider.family<ResultEntity?, String>((ref, matchId) async {
  final useCase = ref.watch(getResultByMatchUseCaseProvider);
  final result = await useCase(matchId);
  return result.fold((_) => null, (r) => r);
});
