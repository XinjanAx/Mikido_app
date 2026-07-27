import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/player_remote_datasource.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/usecases/player_usecases.dart';

final playerRemoteDataSourceProvider = Provider<PlayerRemoteDataSource>(
  (ref) => PlayerRemoteDataSourceImpl(Supabase.instance.client),
);

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => PlayerRepositoryImpl(ref.watch(playerRemoteDataSourceProvider)),
);

final getPlayersUseCaseProvider = Provider(
  (ref) => GetPlayersUseCase(ref.watch(playerRepositoryProvider)),
);
final createPlayerUseCaseProvider = Provider(
  (ref) => CreatePlayerUseCase(ref.watch(playerRepositoryProvider)),
);
final updatePlayerUseCaseProvider = Provider(
  (ref) => UpdatePlayerUseCase(ref.watch(playerRepositoryProvider)),
);
final deletePlayerUseCaseProvider = Provider(
  (ref) => DeletePlayerUseCase(ref.watch(playerRepositoryProvider)),
);
final enrollPlayerUseCaseProvider = Provider(
  (ref) => EnrollPlayerUseCase(ref.watch(playerRepositoryProvider)),
);
final getPlayersByTournamentUseCaseProvider = Provider(
  (ref) => GetPlayersByTournamentUseCase(ref.watch(playerRepositoryProvider)),
);

// ---------- State ----------

class PlayersState {
  final List<PlayerEntity> players;
  final bool isLoading;
  final String? errorMessage;

  const PlayersState({
    this.players = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PlayersState copyWith({
    List<PlayerEntity>? players,
    bool? isLoading,
    String? errorMessage,
  }) =>
      PlayersState(
        players: players ?? this.players,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class PlayersNotifier extends StateNotifier<PlayersState> {
  final GetPlayersUseCase _getAll;
  final CreatePlayerUseCase _create;
  final UpdatePlayerUseCase _update;
  final DeletePlayerUseCase _delete;
  final EnrollPlayerUseCase _enroll;

  PlayersNotifier({
    required GetPlayersUseCase getAll,
    required CreatePlayerUseCase create,
    required UpdatePlayerUseCase update,
    required DeletePlayerUseCase delete,
    required EnrollPlayerUseCase enroll,
  })  : _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _enroll = enroll,
        super(const PlayersState()) {
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    state = state.copyWith(isLoading: true);
    final result = await _getAll();
    result.fold(
      (f) => state = state.copyWith(isLoading: false, errorMessage: f.message),
      (list) => state = state.copyWith(isLoading: false, players: list),
    );
  }

  Future<bool> createPlayer({
    required String name,
    String? email,
    String? phone,
    DateTime? birthDate,
  }) async {
    final player = PlayerEntity(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      birthDate: birthDate,
    );
    final result = await _create(player);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (created) {
        state = state.copyWith(players: [created, ...state.players]);
        return true;
      },
    );
  }

  Future<bool> updatePlayer(PlayerEntity player) async {
    final result = await _update(player);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (updated) {
        state = state.copyWith(
          players: state.players
              .map((p) => p.id == updated.id ? updated : p)
              .toList(),
        );
        return true;
      },
    );
  }

  Future<bool> deletePlayer(String id) async {
    final result = await _delete(id);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (_) {
        state = state.copyWith(
          players: state.players.where((p) => p.id != id).toList(),
        );
        return true;
      },
    );
  }

  Future<bool> enrollPlayer({
    required String playerId,
    required String tournamentId,
    required String categoryId,
  }) async {
    final result = await _enroll(
      playerId: playerId,
      tournamentId: tournamentId,
      categoryId: categoryId,
    );
    return result.fold((f) {
      state = state.copyWith(errorMessage: f.message);
      return false;
    }, (_) => true);
  }
}

final playersProvider = StateNotifierProvider<PlayersNotifier, PlayersState>(
  (ref) => PlayersNotifier(
    getAll: ref.watch(getPlayersUseCaseProvider),
    create: ref.watch(createPlayerUseCaseProvider),
    update: ref.watch(updatePlayerUseCaseProvider),
    delete: ref.watch(deletePlayerUseCaseProvider),
    enroll: ref.watch(enrollPlayerUseCaseProvider),
  ),
);

final playersByTournamentProvider =
    FutureProvider.family<List<PlayerEntity>, String>(
        (ref, tournamentId) async {
  final useCase = ref.watch(getPlayersByTournamentUseCaseProvider);
  final result = await useCase(tournamentId);
  return result.fold((_) => [], (list) => list);
});
