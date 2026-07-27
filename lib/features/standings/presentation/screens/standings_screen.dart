import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/standing_entity.dart';
import '../providers/standing_provider.dart';

class StandingsScreen extends ConsumerWidget {
  final String tournamentId;

  const StandingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar stream para tiempo real
    final standingsAsync = ref.watch(standingsStreamProvider(tournamentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de posiciones'),
        actions: [
          // Indicador en tiempo real
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('En vivo', style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                )),
              ],
            ),
          ),
        ],
      ),
      body: standingsAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando posiciones...'),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (standings) {
          if (standings.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.leaderboard_outlined,
              title: 'Sin clasificaciones',
              subtitle: 'Las posiciones se actualizarán al registrar resultados',
            );
          }
          return _buildTable(standings);
        },
      ),
    );
  }

  Widget _buildTable(List<StandingEntity> standings) {
    return Column(
      children: [
        // Encabezado de tabla
        Container(
          color: AppColors.surfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Text('PARTICIPANTE', style: AppTextStyles.tableHeader),
              ),
              _HeaderCell('PJ'),
              _HeaderCell('PG'),
              _HeaderCell('PP'),
              _HeaderCell('GF'),
              _HeaderCell('GC'),
              _HeaderCell('DG'),
              _HeaderCell('PTS', isLast: true),
            ],
          ),
        ),
        const Divider(height: 1),
        // Filas de datos
        Expanded(
          child: ListView.separated(
            itemCount: standings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = standings[i];
              final position = i + 1;
              return Container(
                color: position <= 3
                    ? _podiumColor(position).withOpacity(0.05)
                    : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: _PositionBadge(position: position),
                    ),
                    Expanded(
                      child: Text(
                        s.playerName,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: position <= 3
                              ? _podiumColor(position)
                              : AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _DataCell('${s.played}'),
                    _DataCell('${s.won}'),
                    _DataCell('${s.lost}'),
                    _DataCell('${s.goalsFor}'),
                    _DataCell('${s.goalsAgainst}'),
                    _DataCell(
                      s.goalDifference >= 0
                          ? '+${s.goalDifference}'
                          : '${s.goalDifference}',
                      color: s.goalDifference > 0
                          ? AppColors.success
                          : s.goalDifference < 0
                              ? AppColors.error
                              : null,
                    ),
                    _DataCell(
                      '${s.points}',
                      isBold: true,
                      color: AppColors.accent,
                      isLast: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Leyenda
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'PJ: Jugados  PG: Ganados  PP: Perdidos  GF: Goles a favor  GC: Goles en contra  DG: Diferencia  PTS: Puntos',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Color _podiumColor(int position) {
    switch (position) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return AppColors.white;
    }
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool isLast;
  const _HeaderCell(this.label, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isLast ? 40 : 30,
      child: Text(
        label,
        style: AppTextStyles.tableHeader,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final bool isBold;
  final Color? color;
  final bool isLast;

  const _DataCell(this.value, {
    this.isBold = false,
    this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isLast ? 40 : 30,
      child: Text(
        value,
        style: AppTextStyles.tableCell.copyWith(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  final int position;
  const _PositionBadge({required this.position});

  @override
  Widget build(BuildContext context) {
    if (position <= 3) {
      final colors = [AppColors.gold, AppColors.silver, AppColors.bronze];
      return Icon(Icons.emoji_events, color: colors[position - 1], size: 18);
    }
    return Text(
      '$position',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
      textAlign: TextAlign.center,
    );
  }
}
