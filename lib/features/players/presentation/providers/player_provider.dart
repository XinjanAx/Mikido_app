import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../tournaments/presentation/providers/tournament_provider.dart'
    show tournamentByIdProvider;
import '../../data/datasources/player_local_datasource.dart';
import '../../data/datasources/player_remote_datasource.dart';
import '../../data/repositories/player_repository_impl.dart';
import '../../data/sync/enrollment_sync_adapter.dart';
import '../../data/sync/player_sync_adapter.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/usecases/player_usecases.dart';

final playerRemoteDataSourceProvider = Provider<PlayerRemoteDataSource>(
  (ref) => PlayerRemoteDataSourceImpl(Supabase.instance.client),
);

final playerLocalDataSourceProvider = Provider<PlayerLocalDataSource>(
  (ref) => PlayerLocalDataSourceImpl(ref.watch(appDatabaseProvider)),
);

final playerSyncAdapterProvider = Provider<PlayerSyncAdapter>(
  (ref) => PlayerSyncAdapter(
    ref.watch(playerRemoteDataSourceProvider),
    ref.watch(playerLocalDataSourceProvider),
  ),
);

final enrollmentSyncAdapterProvider = Provider<EnrollmentSyncAdapter>(
  (ref) => EnrollmentSyncAdapter(
    ref.watch(playerRemoteDataSourceProvider),
    ref.watch(playerLocalDataSourceProvider),
  ),
);

final playerRepositoryProvider = Provider<PlayerRepository>(
  (ref) => PlayerRepositoryImpl(
    ref.watch(playerLocalDataSourceProvider),
    ref.watch(appDatabaseProvider),
    ref.watch(syncEngineProvider),
  ),
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
final unenrollPlayerUseCaseProvider = Provider(
  (ref) => UnenrollPlayerUseCase(ref.watch(playerRepositoryProvider)),
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
  final PlayerRepository _repository;
  final GetPlayersUseCase _getAll;
  final CreatePlayerUseCase _create;
  final UpdatePlayerUseCase _update;
  final DeletePlayerUseCase _delete;
  final EnrollPlayerUseCase _enroll;
  final UnenrollPlayerUseCase _unenroll;
  late final StreamSubscription<List<PlayerEntity>> _playersSub;

  PlayersNotifier({
    required PlayerRepository repository,
    required GetPlayersUseCase getAll,
    required CreatePlayerUseCase create,
    required UpdatePlayerUseCase update,
    required DeletePlayerUseCase delete,
    required EnrollPlayerUseCase enroll,
    required UnenrollPlayerUseCase unenroll,
  })  : _repository = repository,
        _getAll = getAll,
        _create = create,
        _update = update,
        _delete = delete,
        _enroll = enroll,
        _unenroll = unenroll,
        super(const PlayersState()) {
    // Reactivo en vez de una sola carga al crearse: si la sincronización
    // trae jugadores (u otro dispositivo/pantalla crea uno) después de
    // este momento, este stream lo refleja solo — antes, con un único
    // `loadPlayers()` al construirse, la lista se quedaba obsoleta para
    // siempre si eso pasaba después del primer fetch.
    state = state.copyWith(isLoading: true);
    _playersSub = _repository.watchPlayers().listen(
      (list) => state = state.copyWith(isLoading: false, players: list),
      onError: (Object e) =>
          state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  @override
  void dispose() {
    _playersSub.cancel();
    super.dispose();
  }

  /// Refresco manual puntual (p. ej. pull-to-refresh) — el stream del
  /// constructor ya mantiene la lista al día solo, así que en general no
  /// hace falta llamarlo.
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
    String? guild,
    String? guildAcronym,
  }) async {
    final player = PlayerEntity(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      birthDate: birthDate,
      guild: guild,
      guildAcronym: guildAcronym,
    );
    final result = await _create(player);
    // No hace falta tocar `state.players` acá: el stream del constructor
    // (watchPlayers()) ya reacciona solo a la escritura local y trae la
    // lista correcta de la base — actualizarla también a mano acá
    // duplicaba momentáneamente al participante recién creado hasta que
    // el stream volvía a emitir y corregía la lista.
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> updatePlayer(PlayerEntity player) async {
    final result = await _update(player);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> deletePlayer(String id) async {
    final result = await _delete(id);
    return result.fold(
      (f) {
        state = state.copyWith(errorMessage: f.message);
        return false;
      },
      (_) => true,
    );
  }

  Future<bool> enrollPlayer({
    required String playerId,
    required String tournamentId,
  }) async {
    final result = await _enroll(
      playerId: playerId,
      tournamentId: tournamentId,
    );
    return result.fold((f) {
      state = state.copyWith(errorMessage: f.message);
      return false;
    }, (_) => true);
  }

  Future<bool> unenrollPlayer({
    required String playerId,
    required String tournamentId,
  }) async {
    final result =
        await _unenroll(playerId: playerId, tournamentId: tournamentId);
    return result.fold((f) {
      state = state.copyWith(errorMessage: f.message);
      return false;
    }, (_) => true);
  }
}

/// Acrónimo del gremio por id de participante (solo los que tienen).
/// Para mostrar "Nombre - ACRO" en encuentros: los partidos guardan solo el
/// nombre, así que el acrónimo se busca acá (y se actualiza solo si cambia).
final playerAcronymsProvider = Provider<Map<String, String>>((ref) {
  final players = ref.watch(playersProvider).players;
  return {
    for (final p in players)
      if (p.guildAcronym != null && p.guildAcronym!.isNotEmpty)
        p.id: p.guildAcronym!,
  };
});

/// "Nombre - ACRO" si el participante [playerId] tiene gremio.
String nameWithAcronym(
        Map<String, String> acronyms, String playerId, String name) =>
    acronyms[playerId] == null ? name : '$name - ${acronyms[playerId]}';

/// Nombre completo del gremio por id de participante (solo los que tienen).
final playerGuildsProvider = Provider<Map<String, String>>((ref) {
  final players = ref.watch(playersProvider).players;
  return {
    for (final p in players)
      if (p.guild != null && p.guild!.isNotEmpty) p.id: p.guild!,
  };
});

/// "Nombre - Gremio completo" si el participante [playerId] tiene gremio.
String nameWithGuild(Map<String, String> guilds, String playerId, String name) =>
    guilds[playerId] == null ? name : '$name - ${guilds[playerId]}';

final playersProvider = StateNotifierProvider<PlayersNotifier, PlayersState>(
  (ref) => PlayersNotifier(
    repository: ref.watch(playerRepositoryProvider),
    getAll: ref.watch(getPlayersUseCaseProvider),
    create: ref.watch(createPlayerUseCaseProvider),
    update: ref.watch(updatePlayerUseCaseProvider),
    delete: ref.watch(deletePlayerUseCaseProvider),
    enroll: ref.watch(enrollPlayerUseCaseProvider),
    unenroll: ref.watch(unenrollPlayerUseCaseProvider),
  ),
);

final playersByTournamentProvider =
    FutureProvider.family<List<PlayerEntity>, String>(
        (ref, tournamentId) async {
  final useCase = ref.watch(getPlayersByTournamentUseCaseProvider);
  final result = await useCase(tournamentId);
  return result.fold((_) => [], (list) => list);
});

/// Inscripciones de un jugador que realmente bloquean su borrado —
/// autolimpia (local + remoto) las que apuntan a un torneo que ya no
/// existe. Antes de esto una fila huérfana (p. ej. porque el torneo se
/// borró sin borrar sus inscripciones en cascada) dejaba al participante
/// bloqueado para siempre, sin ninguna forma de solucionarlo desde la UI.
Future<List<({String id, String tournamentId, String playerId})>>
    resolveActiveEnrollments(WidgetRef ref, String playerId) async {
  final all = await ref.read(playerLocalDataSourceProvider).getAllEnrollments();
  final mine = all.where((e) => e.playerId == playerId).toList();
  final active = <({String id, String tournamentId, String playerId})>[];
  for (final e in mine) {
    final tournament = ref.read(tournamentByIdProvider(e.tournamentId));
    if (tournament == null) {
      await ref.read(playerLocalDataSourceProvider).hardDeleteEnrollment(e.id);
      await ref
          .read(appDatabaseProvider)
          .enqueueDelete(SupabaseConstants.enrollmentsTable, e.id);
    } else {
      active.add(e);
    }
  }
  return active;
}
