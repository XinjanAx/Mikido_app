import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournament_card_widget.dart';

class TournamentListScreen extends ConsumerWidget {
  const TournamentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () =>
                ref.read(tournamentsProvider.notifier).loadTournaments(),
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
              onPressed: () => ref.read(authProvider.notifier).logout(),
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
          return TournamentCard(
            tournament: t,
            isAdmin: isAdmin,
            onTap: () => context.push(
              RouteConstants.tournamentDetail.replaceAll(':id', t.id),
            ),
            onDelete: isAdmin
                ? () => _confirmDelete(context, ref, t.id, t.name)
                : null,
          );
        },
      ),
    );
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
}
