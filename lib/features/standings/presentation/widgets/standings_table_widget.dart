import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/standing_entity.dart';

/// Widget reutilizable que renderiza la tabla de posiciones.
/// Puede usarse tanto en [StandingsScreen] como embebido
/// dentro del detalle del torneo.
class StandingsTableWidget extends StatelessWidget {
  final List<StandingEntity> standings;
  final bool compact;

  const StandingsTableWidget({
    super.key,
    required this.standings,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (standings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.leaderboard_outlined,
                  color: AppColors.grey600, size: 48),
              const SizedBox(height: 12),
              Text(
                'Sin posiciones aún',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.grey400),
              ),
              const SizedBox(height: 4),
              Text(
                'Se actualizan al registrar resultados',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.grey600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Encabezado
        _TableHeader(compact: compact),
        const Divider(height: 1),
        // Filas
        ...standings.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Column(
            children: [
              _TableRow(
                position: i + 1,
                standing: s,
                compact: compact,
              ),
              if (i < standings.length - 1) const Divider(height: 1),
            ],
          );
        }),
        // Leyenda (solo en modo completo)
        if (!compact)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'PJ: Jugados · PG: Ganados · PP: Perdidos · GF: Goles favor · GC: Goles contra · DG: Diferencia · PTS: Puntos',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final bool compact;
  const _TableHeader({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 32),
          Expanded(
            child: Text('PARTICIPANTE', style: AppTextStyles.tableHeader),
          ),
          _H('PJ'),
          _H('PG'),
          _H('PP'),
          if (!compact) ...[
            _H('GF'),
            _H('GC'),
            _H('DG'),
          ],
          _H('PTS', bold: true),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final int position;
  final StandingEntity standing;
  final bool compact;

  const _TableRow({
    required this.position,
    required this.standing,
    required this.compact,
  });

  Color get _positionColor {
    switch (position) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return AppColors.grey400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: position <= 3
          ? _positionColor.withOpacity(0.05)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: position <= 3
                ? Icon(Icons.emoji_events,
                    color: _positionColor, size: 18)
                : Text(
                    '$position',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.grey600),
                    textAlign: TextAlign.center,
                  ),
          ),
          Expanded(
            child: Text(
              standing.playerName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: position <= 3 ? _positionColor : AppColors.white,
                fontWeight: position == 1
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _D('${standing.played}'),
          _D('${standing.won}'),
          _D('${standing.lost}'),
          if (!compact) ...[
            _D('${standing.goalsFor}'),
            _D('${standing.goalsAgainst}'),
            _D(
              standing.goalDifference >= 0
                  ? '+${standing.goalDifference}'
                  : '${standing.goalDifference}',
              color: standing.goalDifference > 0
                  ? AppColors.success
                  : standing.goalDifference < 0
                      ? AppColors.error
                      : null,
            ),
          ],
          _D('${standing.points}',
              bold: true, color: AppColors.accent),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String label;
  final bool bold;
  const _H(this.label, {this.bold = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 32,
        child: Text(
          label,
          style: AppTextStyles.tableHeader.copyWith(
            fontWeight:
                bold ? FontWeight.w700 : FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );
}

class _D extends StatelessWidget {
  final String value;
  final bool bold;
  final Color? color;
  const _D(this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 32,
        child: Text(
          value,
          style: AppTextStyles.tableCell.copyWith(
            fontWeight:
                bold ? FontWeight.w700 : FontWeight.w400,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      );
}
