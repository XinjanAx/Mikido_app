import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/services/elimination_bracket_service.dart';

/// Diálogo de confirmación antes de generar la siguiente ronda del cuadro
/// de eliminatorias: muestra la lista de jugadores que pasan y solo
/// genera la ronda si el admin acepta. Si rechaza, no se genera nada y
/// puede corregir los marcadores que acaba de guardar.
Future<bool> showRoundAdvanceConfirmDialog(
  BuildContext context,
  PendingRoundAdvance pending,
) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text('¿Pasan a ${pending.nextRound}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${pending.completedRound} terminó. Confirma que estos '
            'jugadores son los que avanzan:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final w in pending.winners)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              size: 16, color: AppColors.gold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(w.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (pending.thirdPlacePlayers != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.military_tech_outlined,
                    size: 16, color: AppColors.grey600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'También se genera el partido por el 3er puesto: '
                    '${pending.thirdPlacePlayers![0].name} vs '
                    '${pending.thirdPlacePlayers![1].name}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.grey600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Rechazar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Aceptar'),
        ),
      ],
    ),
  );
  return result ?? false;
}
