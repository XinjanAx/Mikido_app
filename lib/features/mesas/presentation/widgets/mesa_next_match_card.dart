import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/category_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../players/presentation/providers/player_provider.dart'
    show playerAcronymsProvider, nameWithAcronym;
import '../../../tournaments/domain/entities/tournament_entity.dart';
import '../../../fixtures/presentation/widgets/match_card_widget.dart'
    show MesaTurnBadge;
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../../../tournaments/presentation/widgets/category_color_widgets.dart';
import '../providers/mesa_provider.dart';

/// Acceso visible a la cola de la mesa: muestra el SIGUIENTE encuentro a
/// jugar (de cualquier categoría de la mesa) y, al tocarla, abre el orden
/// completo (MesaQueueScreen).
class MesaNextMatchCard extends ConsumerWidget {
  final String mesaId;

  const MesaNextMatchCard({super.key, required this.mesaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(mesaQueueProvider(mesaId)).valueOrNull ?? const [];
    final next = queue.where((m) => !m.isFinished).firstOrNull;
    final acronyms = ref.watch(playerAcronymsProvider);
    final category = next == null
        ? null
        : ref.watch(tournamentByIdProvider(next.tournamentId));
    final played = queue.where((m) => m.isFinished).length;

    final String subtitle;
    if (queue.isEmpty) {
      subtitle = 'Aún no hay encuentros generados en esta mesa';
    } else if (next == null) {
      subtitle = 'Todos los encuentros de la mesa ya se jugaron';
    } else {
      // Total final (incluye rondas de eliminación por generar).
      subtitle =
          '$played de ${ref.watch(mesaProjectedTotalProvider(mesaId))} jugados';
    }

    final isAdmin = ref.watch(isAdminProvider);
    final card = _buildCard(context, next, category, subtitle, acronyms);
    if (!isAdmin) return card;

    // Solo el admin ve (y puede abrir) Mesa en vivo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => context
                  .push(RouteConstants.mesaLive.replaceAll(':id', mesaId)),
              icon: const Icon(Icons.tv),
              label: const Text('MESA EN VIVO',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context,
      MatchEntity? next,
      TournamentEntity? category,
      String subtitle,
      Map<String, String> acronyms) {
    // El siguiente se resalta con el color de SU categoría.
    final highlight = CategoryColors.parse(category?.color) ?? AppColors.accent;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: next != null ? highlight : AppColors.border,
          width: next != null ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () =>
            context.push(RouteConstants.mesaQueue.replaceAll(':id', mesaId)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (category != null)
                CategoryColorStrip(hex: category.color, width: 6),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.format_list_numbered,
                          color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Orden de encuentros',
                                style: AppTextStyles.titleMedium),
                            if (next != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  MesaTurnBadge(
                                    turn: next.mesaOrder!,
                                    highlighted: true,
                                    highlightColor: highlight,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'SIGUIENTE',
                                          style:
                                              AppTextStyles.labelSmall.copyWith(
                                            color: highlight,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        Text(
                                          '${nameWithAcronym(acronyms, next.homePlayerId, next.homePlayerName)}'
                                          '  vs  '
                                          '${nameWithAcronym(acronyms, next.awayPlayerId, next.awayPlayerName)}',
                                          style: AppTextStyles.bodyMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (category != null)
                                          Text(
                                            [
                                              category.name,
                                              if (next.round != null)
                                                next.round!,
                                            ].join(' · '),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                    color: AppColors.grey400),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(subtitle,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.grey400)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.grey400),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
