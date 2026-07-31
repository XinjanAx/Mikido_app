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
import '../../../../core/constants/app_constants.dart';
import '../../../notifications/domain/usecases/schedule_notifications_usecase.dart';
import '../../../notifications/presentation/providers/notification_provider.dart'
    show scheduleNotificationsUseCaseProvider;

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
  final TournamentRepository _repository;
  final GetTournamentsUseCase _getAll;
  final CreateTournamentUseCase _create;
  final UpdateTournamentUseCase _update;
  final DeleteTournamentUseCase _delete;
  final ScheduleNotificationsUseCase _scheduleNotifications;
  final String _userId;
  late final StreamSubscription<List<TournamentEntity>> _tournamentsSub;

  TournamentsNotifier({
    required TournamentRepository repository,
    required GetTournamentsUseCase getAll,
    required CreateTournamentUseCase create,
    required UpdateTournamentUseCase update,
    required DeleteTournamentUseCase delete,
    required ScheduleNotificationsUseCase scheduleNotifications,
    required String userId,
  })  : _repository = repository,
        _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _scheduleNotifications = scheduleNotifications,
        _userId = userId,
        super(const TournamentsState()) {
    // Reactivo en vez de una sola carga al crearse: si algo cambia el
    // torneo por fuera de esta misma pantalla (p. ej. generar encuentros
    // pasa el torneo de Borrador a Activo desde la pantalla de Fixtures),
    // esto lo refleja solo en vez de quedarse con el valor viejo hasta
    // que se vuelva a crear el provider.
    state = state.copyWith(isLoading: true);
    _tournamentsSub = _repository.watchTournaments().listen(
      (list) => state = state.copyWith(isLoading: false, tournaments: list),
      onError: (Object e) =>
          state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  @override
  void dispose() {
    _tournamentsSub.cancel();
    super.dispose();
  }

  /// Refresco manual puntual (p. ej. pull-to-refresh) — el stream del
  /// constructor ya mantiene la lista al día solo, así que en general no
  /// hace falta llamarlo.
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
        unawaited(_scheduleNotifications.schedule(
          tournamentId: created.id,
          tournamentName: created.name,
          startDate: created.startDate,
          endDate: created.endDate,
        ));
        // No hace falta agregar `created` a `state.tournaments` acá: el
        // stream del constructor (watchTournaments()) ya reacciona solo a
        // la escritura local y trae la lista correcta de la base —
        // hacerlo también a mano acá duplicaba momentáneamente el torneo
        // recién creado hasta que el stream volvía a emitir y corregía
        // la lista (mismo bug que había en PlayersNotifier).
        state = state.copyWith(isLoading: false);
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
        // Las fechas pueden haber cambiado: se reprograman desde cero.
        unawaited(_scheduleNotifications.cancel(updated.id).then((_) =>
            _scheduleNotifications.schedule(
              tournamentId: updated.id,
              tournamentName: updated.name,
              startDate: updated.startDate,
              endDate: updated.endDate,
            )));
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
        unawaited(_scheduleNotifications.cancel(id));
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
      repository: ref.watch(tournamentRepositoryProvider),
      getAll: ref.watch(getTournamentsUseCaseProvider),
      create: ref.watch(createTournamentUseCaseProvider),
      update: ref.watch(updateTournamentUseCaseProvider),
      delete: ref.watch(deleteTournamentUseCaseProvider),
      scheduleNotifications: ref.watch(scheduleNotificationsUseCaseProvider),
      userId: userId,
    );
  },
);

// Torneo individual por ID — derivado de la misma lista reactiva de
// tournamentsProvider en vez de una carga propia (que se quedaba
// obsoleta): así refleja solo cualquier cambio, venga de esta pantalla
// o de otra (p. ej. el estado que cambia solo al generar encuentros).
final tournamentByIdProvider = Provider.family<TournamentEntity?, String>(
  (ref, id) {
    final tournaments = ref.watch(tournamentsProvider).tournaments;
    for (final t in tournaments) {
      if (t.id == id) return t;
    }
    return null;
  },
);
