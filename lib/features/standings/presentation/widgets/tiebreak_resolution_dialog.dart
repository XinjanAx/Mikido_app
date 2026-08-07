import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/standing_entity.dart';
import '../../domain/services/tiebreak_detector.dart';

/// Antes de finalizar un torneo con empates sin resolver (mismos puntos Y
/// misma diferencia), pide al admin que decida a mano el orden de cada
/// grupo empatado. Devuelve `{standingId: manualRank}` (0 = mejor ubicado
/// dentro de su grupo) listo para guardar, o `null` si canceló — en ese
/// caso no se guarda nada y el torneo NO se finaliza.
Future<Map<String, int>?> showTiebreakResolutionDialog(
  BuildContext context,
  List<TiedGroup> tiedGroups,
) {
  return showDialog<Map<String, int>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TiebreakResolutionDialog(tiedGroups: tiedGroups),
  );
}

class _TiebreakResolutionDialog extends StatefulWidget {
  final List<TiedGroup> tiedGroups;
  const _TiebreakResolutionDialog({required this.tiedGroups});

  @override
  State<_TiebreakResolutionDialog> createState() =>
      _TiebreakResolutionDialogState();
}

class _TiebreakResolutionDialogState
    extends State<_TiebreakResolutionDialog> {
  late final List<List<StandingEntity>> _remaining = widget.tiedGroups
      .map((g) => List<StandingEntity>.from(g.members))
      .toList();
  late final List<List<StandingEntity>> _resolved =
      widget.tiedGroups.map((_) => <StandingEntity>[]).toList();

  bool get _allResolved => _remaining.every((r) => r.isEmpty);

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _remaining.length; i++) {
      _autoResolveIfLast(i);
    }
  }

  /// Cuando de un grupo empatado queda un solo jugador sin ubicar, no hay
  /// nada que decidir: pasa directo al lugar que le queda.
  void _autoResolveIfLast(int groupIndex) {
    if (_remaining[groupIndex].length == 1) {
      _resolved[groupIndex].add(_remaining[groupIndex].removeAt(0));
    }
  }

  Future<void> _pickWinner(int groupIndex, StandingEntity candidate) async {
    final others = _remaining[groupIndex]
        .where((s) => s.playerId != candidate.playerId)
        .map((s) => s.playerName)
        .join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar desempate'),
        content: Text(
          '¿Confirmas que ${candidate.playerName} queda por delante de '
          '$others en este desempate?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _remaining[groupIndex]
          .removeWhere((s) => s.playerId == candidate.playerId);
      _resolved[groupIndex].add(candidate);
      _autoResolveIfLast(groupIndex);
    });
  }

  void _save() {
    final result = <String, int>{};
    for (final resolved in _resolved) {
      for (var i = 0; i < resolved.length; i++) {
        result[resolved[i].id] = i;
      }
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hay empates sin resolver'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estos jugadores quedaron con el mismo puntaje y la misma '
                'diferencia. Elegí quién queda mejor ubicado en cada caso.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < widget.tiedGroups.length; i++) ...[
                _TiedGroupCard(
                  group: widget.tiedGroups[i],
                  remaining: _remaining[i],
                  resolved: _resolved[i],
                  onPick: (candidate) => _pickWinner(i, candidate),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _allResolved ? _save : null,
          child: const Text('Guardar y finalizar torneo'),
        ),
      ],
    );
  }
}

class _TiedGroupCard extends StatelessWidget {
  final TiedGroup group;
  final List<StandingEntity> remaining;
  final List<StandingEntity> resolved;
  final ValueChanged<StandingEntity> onPick;

  const _TiedGroupCard({
    required this.group,
    required this.remaining,
    required this.resolved,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final points = group.members.first.points;
    final label = group.groupLabel != null
        ? '${group.groupLabel} — empate en $points pts'
        : 'Empate en $points pts';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < resolved.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text('${i + 1}. ${resolved[i].playerName}',
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
          if (remaining.length > 1) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in remaining)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error),
                    onPressed: () => onPick(s),
                    child: Text('${s.playerName} ganó'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
