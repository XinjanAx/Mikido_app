import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/match_entity.dart';

/// Widget que dibuja el cuadro eliminatorio de forma visual.
/// Agrupa los partidos por ronda y los conecta con líneas.
class BracketWidget extends StatelessWidget {
  final Map<String, List<MatchEntity>> matchesByRound;

  const BracketWidget({super.key, required this.matchesByRound});

  @override
  Widget build(BuildContext context) {
    if (matchesByRound.isEmpty) {
      return const Center(
        child: Text('Sin partidos generados'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: matchesByRound.entries.map((entry) {
          return _RoundColumn(
            roundName: entry.key,
            matches: entry.value,
          );
        }).toList(),
      ),
    );
  }
}

class _RoundColumn extends StatelessWidget {
  final String roundName;
  final List<MatchEntity> matches;

  const _RoundColumn({
    required this.roundName,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Encabezado de ronda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Text(
              roundName,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Tarjetas de partidos
          ...matches.map((m) => _BracketMatchCard(match: m)),
        ],
      ),
    );
  }
}

class _BracketMatchCard extends StatelessWidget {
  final MatchEntity match;

  const _BracketMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: match.isFinished
              ? AppColors.primary.withOpacity(0.4)
              : const Color(0xFF3A3A3A),
        ),
      ),
      child: Column(
        children: [
          _PlayerRow(
            name: match.homePlayerName,
            score: match.homeScore,
            isWinner: _isHomeWinner,
          ),
          const Divider(height: 1),
          _PlayerRow(
            name: match.awayPlayerName,
            score: match.awayScore,
            isWinner: _isAwayWinner,
          ),
        ],
      ),
    );
  }

  bool get _isHomeWinner =>
      match.isFinished &&
      match.homeScore != null &&
      match.awayScore != null &&
      match.homeScore! > match.awayScore!;

  bool get _isAwayWinner =>
      match.isFinished &&
      match.homeScore != null &&
      match.awayScore != null &&
      match.awayScore! > match.homeScore!;
}

class _PlayerRow extends StatelessWidget {
  final String name;
  final int? score;
  final bool isWinner;

  const _PlayerRow({
    required this.name,
    required this.score,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.accent.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(Icons.emoji_events,
                  size: 14, color: AppColors.gold),
            ),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isWinner ? AppColors.accent : AppColors.offWhite,
                fontWeight:
                    isWinner ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            score != null ? '$score' : '-',
            style: AppTextStyles.titleMedium.copyWith(
              color: isWinner ? AppColors.accent : AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}
