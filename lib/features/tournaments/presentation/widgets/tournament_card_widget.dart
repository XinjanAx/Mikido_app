import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/category_colors.dart';
import '../../../players/presentation/providers/player_provider.dart'
    show playerGuildsProvider;
import '../../../standings/presentation/providers/podium_provider.dart';
import '../../../standings/presentation/widgets/podium_widgets.dart';
import '../../domain/entities/tournament_entity.dart';
import 'category_color_widgets.dart';

/// Ancho a partir del cual el campeón va en el espacio libre a la derecha
/// de la tarjeta (escritorio); por debajo va dentro, sobre la fecha.
const double _wideCardWidth = 600;

class TournamentCard extends ConsumerWidget {
  final TournamentEntity tournament;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const TournamentCard({
    super.key,
    required this.tournament,
    required this.onTap,
    this.onDelete,
    this.isAdmin = false,
  });

  Color _statusColor() {
    switch (tournament.status) {
      case 'active':
        return AppColors.statusActive;
      case 'finished':
        return AppColors.statusFinished;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.statusDraft;
    }
  }

  IconData _modeIcon() {
    switch (tournament.mode) {
      case 'groups':
        return Icons.grid_view_rounded;
      case 'elimination':
        return Icons.account_tree_outlined;
      case 'league':
        return Icons.emoji_events_outlined;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = CategoryColors.parse(tournament.color);
    final accent = categoryColor ?? AppColors.primary;
    final podium = ref.watch(podiumProvider(tournament.id));
    final champion = podium.isEmpty ? null : podium.first.name;
    final championGuild = podium.isEmpty
        ? null
        : ref.watch(playerGuildsProvider)[podium.first.playerId];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _wideCardWidth;
            // En escritorio, con el campeón a la derecha, el botón de
            // borrar se saca del contenido y va al extremo de la tarjeta.
            final sideChampion = wide && champion != null;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CategoryColorStrip(hex: tournament.color),
                  Expanded(
                    child: _buildContent(
                      accent,
                      inlineChampion: wide ? null : champion,
                      inlineChampionGuild: championGuild,
                      showDelete: !sideChampion,
                    ),
                  ),
                  if (sideChampion) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 220,
                          child: ChampionBadge(
                            name: champion,
                            guild: championGuild,
                            vertical: true,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _deleteButton() ?? const SizedBox(width: 20),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget? _deleteButton() {
    if (!isAdmin || onDelete == null) return null;
    return IconButton(
      icon: Icon(Icons.delete_outline, color: AppColors.grey400, size: 20),
      onPressed: onDelete,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildContent(Color accent,
      {String? inlineChampion,
      String? inlineChampionGuild,
      bool showDelete = true}) {
    final delete = showDelete ? _deleteButton() : null;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_modeIcon(), color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tournament.name,
                  style: AppTextStyles.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (delete != null) delete,
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(label: tournament.modeLabel),
              const SizedBox(width: 8),
              _StatusBadge(
                label: tournament.statusLabel,
                color: _statusColor(),
              ),
            ],
          ),
          if (inlineChampion != null) ...[
            const SizedBox(height: 12),
            ChampionBadge(name: inlineChampion, guild: inlineChampionGuild),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.grey400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${tournament.startDate.toDisplayDateTime()} → ${tournament.endDate.toDisplayDateTime()}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, style: AppTextStyles.labelSmall),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}
