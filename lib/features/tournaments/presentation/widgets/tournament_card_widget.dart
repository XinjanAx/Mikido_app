import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/category_colors.dart';
import '../../domain/entities/tournament_entity.dart';
import 'category_color_widgets.dart';

class TournamentCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.parse(tournament.color);
    final accent = categoryColor ?? AppColors.primary;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryColorStrip(hex: tournament.color),
              Expanded(child: _buildContent(accent)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color accent) {
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
              if (isAdmin && onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: AppColors.grey400, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
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
