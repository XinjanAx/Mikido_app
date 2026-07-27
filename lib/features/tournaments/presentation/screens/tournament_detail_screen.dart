import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tournament_provider.dart';

class TournamentDetailScreen extends ConsumerWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTournament = ref.watch(tournamentByIdProvider(tournamentId));
    final isAdmin = ref.watch(isAdminProvider);

    return asyncTournament.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (tournament) {
        if (tournament == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Torneo no encontrado')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(tournament.name),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => context.push(
                    RouteConstants.tournamentEdit
                        .replaceAll(':id', tournamentId),
                    extra: tournament,
                  ),
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
                    _InfoRow(label: 'Modalidad', value: tournament.modeLabel),
                    _InfoRow(label: 'Estado', value: tournament.statusLabel),
                    if (tournament.description != null)
                      _InfoRow(
                          label: 'Descripción', value: tournament.description!),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Acciones rápidas
              Text('Módulos', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _buildActionGrid(context, isAdmin),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context, bool isAdmin) {
    final actions = [
      if (isAdmin)
        _QuickAction(
          icon: Icons.category_outlined,
          label: 'Categorías',
          color: AppColors.accent,
          onTap: () => context.push(
            '/tournaments/$tournamentId/categories',
          ),
        ),
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
        label: 'Fixture',
        color: AppColors.warning,
        onTap: () => context.push(
          RouteConstants.fixtures.replaceAll(':id', tournamentId),
        ),
      ),
      _QuickAction(
        icon: Icons.leaderboard_outlined,
        label: 'Posiciones',
        color: AppColors.success,
        onTap: () => context.push(
          RouteConstants.standings.replaceAll(':id', tournamentId),
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
