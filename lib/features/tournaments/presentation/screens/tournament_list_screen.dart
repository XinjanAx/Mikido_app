import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/theme_toggle_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show matchesStreamProvider;
import '../../../mesas/presentation/providers/mesa_provider.dart';
import '../../../mesas/presentation/widgets/mesa_next_match_card.dart';
import '../../domain/entities/tournament_entity.dart';
import '../providers/tournament_provider.dart';
import '../widgets/tournament_card_widget.dart';

/// Detalle de una mesa: sus categorías. (En el código y la base una
/// categoría sigue siendo un "tournament".) Con [mesaId] null muestra las
/// categorías viejas que todavía no tienen mesa.
class TournamentListScreen extends ConsumerWidget {
  final String? mesaId;

  const TournamentListScreen({super.key, required this.mesaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tournamentsProvider);
    final categories = ref.watch(categoriesByMesaProvider(mesaId));
    final mesa = mesaId == null ? null : ref.watch(mesaByIdProvider(mesaId!));
    final isAdmin = ref.watch(isAdminProvider);
    final canCreate = isAdmin && mesa != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(mesaId == null
            ? 'Categorías sin mesa'
            : (mesa?.name ?? 'Mesa')),
        actions: [
          if (mesa != null)
            IconButton(
              icon: const Icon(Icons.format_list_numbered),
              tooltip: 'Orden de la mesa',
              onPressed: () => context
                  .push(RouteConstants.mesaQueue.replaceAll(':id', mesa.id)),
            ),
          if (isAdmin && mesa != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar mesa',
              onPressed: () => context.push(
                RouteConstants.mesaEdit.replaceAll(':id', mesa.id),
                extra: mesa,
              ),
            ),
          const ThemeToggleButton(),
        ],
      ),
      body: _buildBody(context, ref, state, categories, isAdmin, canCreate),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _goCreate(context),
              icon: const Icon(Icons.add),
              label: const Text('Nueva categoría'),
            )
          : null,
    );
  }

  void _goCreate(BuildContext context) => context.push(
      Uri(path: RouteConstants.tournamentCreate, queryParameters: {
        'mesaId': mesaId!,
      }).toString());

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    TournamentsState state,
    List<TournamentEntity> categories,
    bool isAdmin,
    bool canCreate,
  ) {
    if (state.isLoading && state.tournaments.isEmpty) {
      return const LoadingWidget(message: 'Cargando categorías...');
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

    if (categories.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.emoji_events_outlined,
        title: 'Sin categorías',
        subtitle: canCreate
            ? 'Crea la primera categoría de esta mesa'
            : 'Aún no hay categorías en esta mesa',
        actionLabel: canCreate ? 'Crear categoría' : null,
        onAction: canCreate ? () => _goCreate(context) : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tournamentsProvider.notifier).loadTournaments(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        // Primero la tarjeta del orden de la mesa (con el siguiente
        // encuentro), después las categorías.
        itemCount: categories.length + (mesaId != null ? 1 : 0),
        itemBuilder: (_, index) {
          if (mesaId != null && index == 0) {
            return MesaNextMatchCard(mesaId: mesaId!);
          }
          final t = categories[index - (mesaId != null ? 1 : 0)];
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
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: const Text(
            'Esta categoría ya tiene encuentros generados y todavía no ha '
            'finalizado. Solo se puede eliminar si ya finalizó o si no '
            'tiene encuentros generados.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content:
            Text('¿Eliminar "${t.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(tournamentsProvider.notifier).deleteTournament(t.id);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
