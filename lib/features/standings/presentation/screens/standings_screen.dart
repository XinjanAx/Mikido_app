import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show matchesStreamProvider;
import '../../../tournaments/presentation/providers/tournament_provider.dart'
    show tournamentByIdProvider;
import '../../domain/entities/standing_entity.dart';
import '../providers/standing_provider.dart';

class StandingsScreen extends ConsumerWidget {
  final String tournamentId;

  const StandingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar stream para tiempo real
    final standingsAsync = ref.watch(standingsStreamProvider(tournamentId));
    final tournament =
        ref.watch(tournamentByIdProvider(tournamentId)).valueOrNull;
    final isGroups = tournament?.mode == AppConstants.tournamentModeGroups;
    final matches = isGroups
        ? ref.watch(matchesStreamProvider(tournamentId)).valueOrNull ?? []
        : const <MatchEntity>[];

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
          if (isGroups) {
            return _buildGroupedTables(standings, matches);
          }
          return _buildTable(standings);
        },
      ),
    );
  }

  /// Agrupa la tabla de posiciones por grupo (round = "Grupo A", "Grupo B", ...)
  /// usando los partidos del torneo para saber a qué grupo pertenece cada
  /// participante.
  Widget _buildGroupedTables(
      List<StandingEntity> standings, List<MatchEntity> matches) {
    final groupOf = <String, String>{};
    for (final m in matches) {
      final round = m.round;
      if (round == null || !round.startsWith('Grupo')) continue;
      groupOf[m.homePlayerId] = round;
      if (m.awayPlayerId != m.homePlayerId) groupOf[m.awayPlayerId] = round;
    }

    final byGroup = <String, List<StandingEntity>>{};
    for (final s in standings) {
      final group = groupOf[s.playerId] ?? 'Sin grupo';
      byGroup.putIfAbsent(group, () => []).add(s);
    }
    final groupNames = byGroup.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final groupName in groupNames) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Icon(Icons.groups, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  groupName,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _buildHeaderRow(),
          const Divider(height: 1),
          for (final entry in byGroup[groupName]!.asMap().entries) ...[
            _buildDataRow(entry.value, entry.key + 1),
            if (entry.key < byGroup[groupName]!.length - 1)
              const Divider(height: 1),
          ],
        ],
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

  Widget _buildTable(List<StandingEntity> standings) {
    return Column(
      children: [
        _buildHeaderRow(),
        const Divider(height: 1),
        // Filas de datos
        Expanded(
          child: ListView.separated(
            itemCount: standings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _buildDataRow(standings[i], i + 1),
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

  Widget _buildHeaderRow() {
    return Container(
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
    );
  }

  Widget _buildDataRow(StandingEntity s, int position) {
    return Container(
      color: position <= 3 ? _podiumColor(position).withOpacity(0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color:
                    position <= 3 ? _podiumColor(position) : AppColors.textPrimary,
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
        return AppColors.textPrimary;
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
