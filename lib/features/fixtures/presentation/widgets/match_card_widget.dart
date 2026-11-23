import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/match_entity.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback? onTap;
  final bool isAdmin;
  final bool locked;

  /// Pendiente que se registra en Mesa en vivo (no aquí).
  final bool registeredInLive;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.isAdmin = false,
    this.locked = false,
    this.registeredInLive = false,
  });

  @override
  Widget build(BuildContext context) {
    final finished = match.isFinished;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Turno en la mesa (los BYE no tienen)
              if (match.mesaOrder != null) ...[
                MesaTurnBadge(turn: match.mesaOrder!),
                const SizedBox(width: 12),
              ],
              // Local
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.homePlayerName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: finished && _homeWon
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (finished && _homeWon)
                      const Icon(Icons.emoji_events,
                          size: 14, color: AppColors.gold),
                  ],
                ),
              ),
              // Marcador
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: finished
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: finished ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: finished
                    ? Column(
                        children: [
                          Text(
                            '${match.homeScore} - ${match.awayScore}',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          if (locked)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline,
                                    size: 10, color: AppColors.grey400),
                                const SizedBox(width: 2),
                                Text('Ronda cerrada',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.grey400,
                                      fontSize: 9,
                                    )),
                              ],
                            )
                          else if (isAdmin && onTap != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 10, color: AppColors.grey400),
                                const SizedBox(width: 2),
                                Text('Editar',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.grey400,
                                      fontSize: 9,
                                    )),
                              ],
                            ),
                        ],
                      )
                    : Column(
                        children: [
                          Text('vs', style: AppTextStyles.bodySmall),
                          if (isAdmin)
                            Text(registeredInLive ? 'En vivo' : 'Registrar',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: registeredInLive
                                      ? AppColors.grey400
                                      : AppColors.primary,
                                )),
                        ],
                      ),
              ),
              // Visitante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      match.awayPlayerName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: finished && _awayWon
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                    if (finished && _awayWon)
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.emoji_events,
                            size: 14, color: AppColors.gold),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _homeWon =>
      match.homeScore != null &&
      match.awayScore != null &&
      match.homeScore! > match.awayScore!;

  bool get _awayWon =>
      match.homeScore != null &&
      match.awayScore != null &&
      match.awayScore! > match.homeScore!;
}

/// Número de turno del encuentro en la cola de su mesa.
class MesaTurnBadge extends StatelessWidget {
  final int turn;
  final bool highlighted;

  /// Color al resaltar (el de la categoría). Por defecto, accent.
  final Color? highlightColor;

  const MesaTurnBadge({
    super.key,
    required this.turn,
    this.highlighted = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        highlighted ? (highlightColor ?? AppColors.accent) : AppColors.grey400;
    return Tooltip(
      message: 'Turno $turn en la mesa',
      child: Container(
        constraints: const BoxConstraints(minWidth: 34),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          '#$turn',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
