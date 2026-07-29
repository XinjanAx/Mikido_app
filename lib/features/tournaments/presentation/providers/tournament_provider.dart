import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../data/datasources/tournament_local_datasource.dart';
import '../../data/datasources/tournament_remote_datasource.dart';
import '../../data/repositories/tournament_repository_impl.dart';
import '../../data/sync/tournament_sync_adapter.dart';
import '../../domain/entities/tournament_entity.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../../domain/usecases/tournament_usecases.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../categories/presentation/providers/category_provider.dart'
    show createCategoryUseCaseProvider;
import '../../../../core/constants/app_constants.dart';

// Infrastructure
final tournamentRemoteDataSourceProvider = Provider<TournamentRemoteDataSource>(
  (ref) => TournamentRemoteDataSourceImpl(Supabase.instance.client),
);

final tournamentLocalDataSourceProvider = Provider<TournamentLocalDataSource>(
  (ref) => TournamentLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final tournamentSyncAdapterProvider = Provider<TournamentSyncAdapter>(
  (ref) => TournamentSyncAdapter(
    ref.watch(tournamentRemoteDataSourceProvider),
    ref.watch(tournamentLocalDataSourceProvider),
  ),
);

final tournamentRepositoryProvider = Provider<TournamentRepository>(
  (ref) => TournamentRepositoryImpl(
    ref.watch(tournamentLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  ),
);

// Use cases
final getTournamentsUseCaseProvider = Provider(
  (ref) => GetTournamentsUseCase(ref.watch(tournamentRepositoryProvider)),
);
final getTournamentByIdUseCaseProvider = Provider(
  (ref) => GetTournamentByIdUseCase(ref.watch(tournamentRepositoryProvider)),
);
final createTournamentUseCaseProvider = Provider(
  (ref) => CreateTournamentUseCase(ref.watch(tournamentRepositoryProvider)),
);
final updateTournamentUseCaseProvider = Provider(
  (ref) => UpdateTournamentUseCase(ref.watch(tournamentRepositoryProvider)),
);
final deleteTournamentUseCaseProvider = Provider(
  (ref) => DeleteTournamentUseCase(ref.watch(tournamentRepositoryProvider)),
);

// ---------- State ----------

class TournamentsState {
  final List<TournamentEntity> tournaments;
  final bool isLoading;
  final String? errorMessage;

  const TournamentsState({
    this.tournaments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TournamentsState copyWith({
    List<TournamentEntity>? tournaments,
    bool? isLoading,
    String? errorMessage,
  }) =>
      TournamentsState(
        tournaments: tournaments ?? this.tournaments,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class TournamentsNotifier extends StateNotifier<TournamentsState> {
  final GetTournamentsUseCase _getAll;
  final CreateTournamentUseCase _create;
  final UpdateTournamentUseCase _update;
  final DeleteTournamentUseCase _delete;
  final CreateCategoryUseCase _createCategory;
  final String _userId;

  TournamentsNotifier({
    required GetTournamentsUseCase getAll,
    required CreateTournamentUseCase create,
    required UpdateTournamentUseCase update,
    required DeleteTournamentUseCase delete,
    required CreateCategoryUseCase createCategory,
    required String userId,
  })  : _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _createCategory = createCategory,
        _userId = userId,
        super(const TournamentsState()) {
    loadTournaments();
  }

  Future<void> loadTournaments() async {
    state = state.copyWith(isLoading: true);
    final result = await _getAll();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (list) => state = state.copyWith(
        isLoading: false,
        tournaments: list,
      ),
    );
  }

  Future<bool> createTournament({
    required String name,
    required String mode,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true);
    final tournament = TournamentEntity(
      id: const Uuid().v4(),
      name: name,
      mode: mode,
      status: AppConstants.statusDraft,
      description: description,
      startDate: startDate,
      endDate: endDate,
      createdBy: _userId,
    );
    final result = await _create(tournament);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (created) {
        // Ya no se pide elegir/crear categoría en la app: cada torneo
        // recibe una única categoría "General" automática por dentro, que
        // sigue usando toda la lógica existente de inscripciones/fixture.
        unawaited(_createCategory(CategoryEntity(
          id: const Uuid().v4(),
          name: 'General',
          tournamentId: created.id,
        )));
        state = state.copyWith(
          isLoading: false,
          tournaments: [created, ...state.tournaments],
        );
        return true;
      },
    );
  }

  Future<bool> updateTournament(TournamentEntity tournament) async {
    final result = await _update(tournament);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updated) {
        state = state.copyWith(
          tournaments: state.tournaments
              .map((t) => t.id == updated.id ? updated : t)
              .toList(),
        );
        return true;
      },
    );
  }

  Future<bool> deleteTournament(String id) async {
    final result = await _delete(id);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          tournaments: state.tournaments.where((t) => t.id != id).toList(),
        );
        return true;
      },
    );
  }
}

final tournamentsProvider =
    StateNotifierProvider<TournamentsNotifier, TournamentsState>(
  (ref) {
    final userId = ref.watch(currentUserProvider)?.id ?? '';
    return TournamentsNotifier(
      getAll: ref.watch(getTournamentsUseCaseProvider),
      create: ref.watch(createTournamentUseCaseProvider),
      update: ref.watch(updateTournamentUseCaseProvider),
      delete: ref.watch(deleteTournamentUseCaseProvider),
      createCategory: ref.watch(createCategoryUseCaseProvider),
      userId: userId,
    );
  },
);

// Torneo individual por ID
final tournamentByIdProvider =
    FutureProvider.family<TournamentEntity?, String>((ref, id) async {
  final useCase = ref.watch(getTournamentByIdUseCaseProvider);
  final result = await useCase(id);
  return result.fold((_) => null, (t) => t);
});
