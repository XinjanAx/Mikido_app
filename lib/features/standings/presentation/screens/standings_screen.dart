import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_app/features/tournaments/presentation/widgets/category_color_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_footer.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/tournament_phase_header.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart'
    show matchesStreamProvider;
import '../../../tournaments/presentation/providers/tournament_provider.dart'
    show tournamentByIdProvider;
import '../../domain/entities/standing_entity.dart';
import '../../../players/presentation/providers/player_provider.dart'
    show playerGuildsProvider, nameWithGuild;
import '../providers/standing_provider.dart';

class StandingsScreen extends ConsumerWidget {
  final String tournamentId;

  const StandingsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar stream para tiempo real
    final standingsAsync = ref.watch(standingsStreamProvider(tournamentId));
    final tournament = ref.watch(tournamentByIdProvider(tournamentId));
    final isGroups = tournament?.mode == AppConstants.tournamentModeGroups;
    final matches = isGroups
        ? ref.watch(matchesStreamProvider(tournamentId)).valueOrNull ?? []
        : const <MatchEntity>[];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: CategoryHeaderGradient(tournamentId: tournamentId),
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
      body: Column(
        children: [
          TournamentPhaseHeader(
            tournamentName: tournament?.name ?? '',
            phaseLabel: isGroups ? 'Fase de grupos' : 'Liga - Todos contra todos',
          ),
          Expanded(
            child: standingsAsync.when(
              loading: () =>
                  const LoadingWidget(message: 'Cargando posiciones...'),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (standings) {
                if (standings.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.leaderboard_outlined,
                    title: 'Sin clasificaciones',
                    subtitle:
                        'Las posiciones se actualizarán al registrar resultados',
                  );
                }
                if (isGroups) {
                  return _buildGroupedTables(standings, matches);
                }
                return _buildTable(standings);
              },
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final groupName in groupNames) ...[
          _StandingsCard(
            title: groupName.toUpperCase(),
            standings: byGroup[groupName]!,
          ),
          const SizedBox(height: 20),
        ],
        const _Legend(),
        const SizedBox(height: 20),
        const BrandFooter(),
      ],
    );
  }

  Widget _buildTable(List<StandingEntity> standings) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _StandingsCard(title: 'TABLA DE POSICIONES', standings: standings),
        const SizedBox(height: 20),
        const _Legend(),
        const SizedBox(height: 20),
        const BrandFooter(),
      ],
    );
  }
}

/// Tarjeta con título (trofeo + nombre), encabezado de columnas y filas de
/// datos — mismo bloque visual para la tabla única (liga) o cada grupo.
class _StandingsCard extends ConsumerWidget {
  final String title;
  final List<StandingEntity> standings;

  const _StandingsCard({required this.title, required this.standings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guilds = ref.watch(playerGuildsProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events,
                      size: 16, color: AppColors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderRow(),
          const Divider(height: 1),
          for (final entry in standings.asMap().entries) ...[
            _buildDataRow(entry.value, entry.key + 1, guilds),
            if (entry.key < standings.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Expanded(
            child: Text('EQUIPO', style: AppTextStyles.tableHeader),
          ),
          _HeaderCell('PJ'),
          _HeaderCell('PG'),
          _HeaderCell('PE'),
          _HeaderCell('PP'),
          _HeaderCell('PF'),
          _HeaderCell('PC'),
          _HeaderCell('DG'),
          _HeaderCell('PTS', isLast: true),
        ],
      ),
    );
  }

  Widget _buildDataRow(
      StandingEntity s, int position, Map<String, String> guilds) {
    return Container(
      color: position <= 3 ? _podiumColor(position).withOpacity(0.05) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: _PositionBadge(position: position),
          ),
          Expanded(
            child: Text(
              // "Nombre - Gremio completo" si tiene gremio.
              nameWithGuild(guilds, s.playerId, s.playerName),
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
          _DataCell('${s.drawn}'),
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
      width: isLast ? 36 : 26,
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
      width: isLast ? 36 : 26,
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

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'PJ: Jugados  PG: Ganados  PE: Empatados  PP: Perdidos  '
        'PF: Puntos a favor  PC: Puntos en contra  DG: Diferencia  PTS: Puntos',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
