import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show matchesStreamProvider;
import '../../../mesas/presentation/providers/mesa_provider.dart'
    show mesaByIdProvider;
import '../../../mesas/presentation/widgets/mesa_next_match_card.dart';
import '../../../standings/presentation/providers/podium_provider.dart';
import '../../../standings/presentation/widgets/podium_widgets.dart';
import '../providers/tournament_provider.dart';
import '../widgets/category_color_widgets.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournament = ref.watch(tournamentByIdProvider(tournamentId));
    final isAdmin = ref.watch(isAdminProvider);
    final hasMatches = ref
            .watch(matchesStreamProvider(tournamentId))
            .valueOrNull
            ?.isNotEmpty ??
        false;
    final podium = ref.watch(podiumProvider(tournamentId));

    if (tournament == null) {
      final isLoading = ref.watch(tournamentsProvider).isLoading;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: isLoading
              ? const LoadingWidget()
              : const Text('Categoría no encontrada'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: CategoryHeaderGradient(tournamentId: tournamentId),
        title: Text(tournament.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: hasMatches
                  ? 'No se puede editar: ya hay encuentros generados'
                  : 'Editar categoría',
              onPressed: () {
                if (hasMatches) {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('No se puede editar'),
                      content: const Text(
                        'Esta categoría ya tiene encuentros generados. Para '
                        'editarlo (por ejemplo, cambiar la modalidad), '
                        'primero elimina los encuentros desde la pantalla '
                        'de Encuentros.',
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
                context.push(
                  RouteConstants.tournamentEdit.replaceAll(':id', tournamentId),
                  extra: tournament,
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Info general
          _SectionCard(
            title: 'Información',
            child: Column(
              children: [
                if (tournament.mesaId != null)
                  _InfoRow(
                    label: 'Mesa',
                    value: ref
                            .watch(mesaByIdProvider(tournament.mesaId!))
                            ?.name ??
                        '—',
                  ),
                _InfoRow(label: 'Modalidad', value: tournament.modeLabel),
                _InfoRow(label: 'Estado', value: tournament.statusLabel),
                if (tournament.description != null)
                  _InfoRow(
                      label: 'Descripción', value: tournament.description!),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Podio (solo con la categoría finalizada).
          if (podium.isNotEmpty) ...[
            PodiumCard(podium: podium),
            const SizedBox(height: 12),
          ],

          // Orden de la mesa (con el siguiente encuentro a jugar).
          if (tournament.mesaId != null) ...[
            MesaNextMatchCard(mesaId: tournament.mesaId!),
            const SizedBox(height: 12),
          ],

          // Acciones rápidas
          Text('Módulos', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildActionGrid(context, isAdmin, tournament.mode),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, bool isAdmin, String mode) {
    final isElimination = mode == AppConstants.tournamentModeElimination;
    final actions = [
      if (isAdmin)
        _QuickAction(
          icon: Icons.people_outline,
          label: 'Participantes',
          color: AppColors.info,
          onTap: () => context.push(
            RouteConstants.playerEnroll.replaceAll(':id', tournamentId),
          ),
        ),
      _QuickAction(
        icon: Icons.account_tree_outlined,
        label: 'Encuentros',
        color: AppColors.warning,
        onTap: () => context.push(
          RouteConstants.fixtures.replaceAll(':id', tournamentId),
        ),
      ),
      _QuickAction(
        icon: isElimination
            ? Icons.account_tree_outlined
            : Icons.leaderboard_outlined,
        label: 'Posiciones',
        color: AppColors.success,
        onTap: () => context.push(
          (isElimination ? RouteConstants.bracket : RouteConstants.standings)
              .replaceAll(':id', tournamentId),
        ),
      ),
      if (isAdmin)
        _QuickAction(
          icon: Icons.picture_as_pdf_outlined,
          label: 'Reportes',
          color: AppColors.accent,
          onTap: () => context.push(
            RouteConstants.reports.replaceAll(':id', tournamentId),
          ),
        ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: actions.map((a) => _QuickActionCard(action: a)).toList(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.grey400)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(action.label,
                  style: AppTextStyles.titleMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
