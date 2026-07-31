import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show matchesStreamProvider;
import '../../domain/entities/tournament_entity.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournament_card_widget.dart';

class TournamentListScreen extends ConsumerStatefulWidget {
  const TournamentListScreen({super.key});

  @override
  ConsumerState<TournamentListScreen> createState() =>
      _TournamentListScreenState();
}

class _TournamentListScreenState extends ConsumerState<TournamentListScreen> {
  static const _seenIntroKey = 'seen_offline_intro';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowIntro());
  }

  Future<void> _maybeShowIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeen = prefs.getBool(_seenIntroKey) ?? false;
    if (alreadySeen || !mounted) return;
    await prefs.setBool(_seenIntroKey, true);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¡Bienvenido!'),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/mikido_wordmark.png',
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'La primera vez inicia sesión con internet para verificar tu cuenta.\n\n'
              'Luego podrás usar la aplicación sin conexión y los cambios se '
              'sincronizarán automáticamente cuando haya internet.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar...'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tournamentsProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Torneos'),
            if (user != null)
              Text(
                'Hola, ${user.name}',
                style: AppTextStyles.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sincronizar',
            onPressed: () => ref.read(syncEngineProvider).trySync(),
          ),
          IconButton(
            icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined),
            tooltip: 'Cambiar tema',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.people_outline),
              onPressed: () => context.push(RouteConstants.players),
            ),
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Cerrar sesión',
              onPressed: () => _confirmLogout(context, ref),
            )
          else
            IconButton(
              icon: const Icon(Icons.login_outlined),
              tooltip: 'Iniciar sesión',
              onPressed: () => context.push(RouteConstants.login),
            ),
        ],
      ),
      body: _buildBody(context, ref, state, isAdmin),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => context.push(RouteConstants.tournamentCreate),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo torneo'),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, TournamentsState state,
      bool isAdmin) {
    if (state.isLoading && state.tournaments.isEmpty) {
      return const LoadingWidget(message: 'Cargando torneos...');
    }

    if (state.errorMessage != null && state.tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(state.errorMessage!, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  ref.read(tournamentsProvider.notifier).loadTournaments(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.tournaments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.emoji_events_outlined,
        title: 'Sin torneos',
        subtitle: isAdmin
            ? 'Crea el primer torneo del club'
            : 'Aún no hay torneos disponibles',
        actionLabel: isAdmin ? 'Crear torneo' : null,
        onAction: isAdmin
            ? () => context.push(RouteConstants.tournamentCreate)
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tournamentsProvider.notifier).loadTournaments(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: state.tournaments.length,
        itemBuilder: (_, i) {
          final t = state.tournaments[i];
          final hasMatches = ref
                  .watch(matchesStreamProvider(t.id))
                  .valueOrNull
                  ?.isNotEmpty ??
              false;
          return TournamentCard(
            tournament: t,
            isAdmin: isAdmin,
            onTap: () => context.push(
              RouteConstants.tournamentDetail.replaceAll(':id', t.id),
            ),
            onDelete: isAdmin
                ? () => _handleDeleteTap(context, ref, t, hasMatches)
                : null,
          );
        },
      ),
    );
  }

  void _handleDeleteTap(BuildContext context, WidgetRef ref,
      TournamentEntity t, bool hasMatches) {
    final isFinished = t.status == AppConstants.statusFinished;
    final canDelete = isFinished || !hasMatches;

    if (!canDelete) {
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: const Text(
            'Este torneo ya tiene encuentros generados y todavía no ha '
            'finalizado. Solo se puede eliminar si ya finalizó o si no '
            'tiene encuentros generados.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    _confirmDelete(context, ref, t.id, t.name);
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar torneo'),
        content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tournamentsProvider.notifier).deleteTournament(id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Seguro que deseas cerrar sesión? Vas a necesitar conexión a '
          'internet para volver a iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
