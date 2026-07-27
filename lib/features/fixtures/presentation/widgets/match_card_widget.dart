import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/match_entity.dart';

class MatchCard extends StatelessWidget {
  final MatchEntity match;
  final VoidCallback? onTap;
  final bool isAdmin;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.isAdmin = false,
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
                            : AppColors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: finished
                      ? AppColors.primary.withOpacity(0.15)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: finished ? AppColors.primary : const Color(0xFF3A3A3A),
                  ),
                ),
                child: finished
                    ? Text(
                        '${match.homeScore} - ${match.awayScore}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      )
                    : Column(
                        children: [
                          Text('vs', style: AppTextStyles.bodySmall),
                          if (isAdmin)
                            Text('Registrar',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
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
                            : AppColors.white,
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
