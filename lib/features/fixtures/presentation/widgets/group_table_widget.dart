import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/match_entity.dart';

/// Muestra una tabla compacta de resultados para un grupo específico.
/// Calcula PJ, PG, PP, GF, GC y Puntos directamente desde los partidos.
class GroupTableWidget extends StatelessWidget {
  final String groupName;
  final List<MatchEntity> matches;

  const GroupTableWidget({
    super.key,
    required this.groupName,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del grupo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              groupName,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),

          // Encabezado de columnas
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 24), // posición
                Expanded(
                    child: Text('JUGADOR',
                        style: AppTextStyles.tableHeader)),
                _ColHeader('PJ'),
                _ColHeader('PG'),
                _ColHeader('PP'),
                _ColHeader('GF'),
                _ColHeader('GC'),
                _ColHeader('PTS', bold: true),
              ],
            ),
          ),
          const Divider(height: 1),

          // Filas de jugadores ordenadas por puntos
          ...rows.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            final isLast = i == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Posición
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: i == 0
                                ? AppColors.gold
                                : AppColors.grey400,
                            fontWeight: i == 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Nombre
                      Expanded(
                        child: Text(
                          row.playerName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: i == 0
                                ? AppColors.accent
                                : AppColors.offWhite,
                            fontWeight: i == 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _ColData('${row.played}'),
                      _ColData('${row.won}'),
                      _ColData('${row.lost}'),
                      _ColData('${row.goalsFor}'),
                      _ColData('${row.goalsAgainst}'),
                      _ColData(
                        '${row.points}',
                        bold: true,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  List<_GroupRow> _buildRows() {
    final playerMap = <String, _GroupRow>{};

    for (final match in matches) {
      // Registrar jugadores si no existen
      playerMap.putIfAbsent(
        match.homePlayerId,
        () => _GroupRow(playerName: match.homePlayerName),
      );
      playerMap.putIfAbsent(
        match.awayPlayerId,
        () => _GroupRow(playerName: match.awayPlayerName),
      );

      if (!match.isFinished) continue;
      if (match.homeScore == null || match.awayScore == null) continue;

      final home = playerMap[match.homePlayerId]!;
      final away = playerMap[match.awayPlayerId]!;

      home.played++;
      away.played++;
      home.goalsFor += match.homeScore!;
      home.goalsAgainst += match.awayScore!;
      away.goalsFor += match.awayScore!;
      away.goalsAgainst += match.homeScore!;

      if (match.homeScore! > match.awayScore!) {
        home.won++;
        home.points += 3;
        away.lost++;
      } else if (match.awayScore! > match.homeScore!) {
        away.won++;
        away.points += 3;
        home.lost++;
      } else {
        home.points++;
        away.points++;
      }
    }

    final rows = playerMap.values.toList();
    rows.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      final diffA = a.goalsFor - a.goalsAgainst;
      final diffB = b.goalsFor - b.goalsAgainst;
      if (diffB != diffA) return diffB.compareTo(diffA);
      return b.goalsFor.compareTo(a.goalsFor);
    });
    return rows;
  }
}

class _GroupRow {
  final String playerName;
  int played = 0;
  int won = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;

  _GroupRow({required this.playerName});
}

class _ColHeader extends StatelessWidget {
  final String label;
  final bool bold;
  const _ColHeader(this.label, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        label,
        style: AppTextStyles.tableHeader.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ColData extends StatelessWidget {
  final String value;
  final bool bold;
  final Color? color;
  const _ColData(this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        value,
        style: AppTextStyles.tableCell.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
