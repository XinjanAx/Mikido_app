import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/category_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/widgets/match_card_widget.dart'
    show MesaTurnBadge;
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../../../tournaments/presentation/widgets/category_color_widgets.dart';
import '../providers/mesa_provider.dart';

/// Orden de encuentros de la mesa: todas sus categorías mezcladas en un
/// solo turno global. El orden lo define el algoritmo (MesaScheduler) y no
/// se puede editar; los resultados se cargan desde Encuentros de cada
/// categoría (tocar un encuentro lleva ahí).
class MesaQueueScreen extends ConsumerStatefulWidget {
  final String mesaId;

  const MesaQueueScreen({super.key, required this.mesaId});

  @override
  ConsumerState<MesaQueueScreen> createState() => _MesaQueueScreenState();
}

class _MesaQueueScreenState extends ConsumerState<MesaQueueScreen> {
  bool _hidePlayed = false;

  @override
  Widget build(BuildContext context) {
    final mesa = ref.watch(mesaByIdProvider(widget.mesaId));
    final queueAsync = ref.watch(mesaQueueProvider(widget.mesaId));
    final playedCount =
        (queueAsync.valueOrNull ?? const []).where((m) => m.isFinished).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(mesa != null ? 'Orden - ${mesa.name}' : 'Orden de la mesa'),
        actions: [
          // Solo tiene sentido si ya hay encuentros jugados que ocultar.
          if (playedCount > 0)
            IconButton(
              icon: Icon(_hidePlayed
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              tooltip: _hidePlayed
                  ? 'Mostrar los $playedCount encuentros jugados'
                  : 'Ocultar los $playedCount encuentros jugados',
              onPressed: () => setState(() => _hidePlayed = !_hidePlayed),
            ),
        ],
      ),
      body: queueAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando orden...'),
        error: (e, _) => Center(child: Text('$e')),
        data: (queue) {
          if (queue.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.format_list_numbered,
              title: 'Sin encuentros',
              subtitle:
                  'Cuando se generen los encuentros de las categorías de esta '
                  'mesa, aparecerán aquí en orden.',
            );
          }

          final played = queue.where((m) => m.isFinished).length;
          final nextIdx = queue.indexWhere((m) => !m.isFinished);
          final visible =
              _hidePlayed ? queue.where((m) => !m.isFinished).toList() : queue;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  '$played de ${queue.length} encuentros jugados',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey400),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: visible.length,
                  itemBuilder: (_, i) {
                    final m = visible[i];
                    final isNext = nextIdx != -1 && m.id == queue[nextIdx].id;
                    return _QueueTile(
                      match: m,
                      isNext: isNext,
                      onTap: () => context.push(RouteConstants.fixtures
                          .replaceAll(':id', m.tournamentId)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QueueTile extends ConsumerWidget {
  final MatchEntity match;
  final bool isNext;
  final VoidCallback onTap;

  const _QueueTile({
    required this.match,
    required this.isNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(tournamentByIdProvider(match.tournamentId));
    final finished = match.isFinished;
    final subtitle = [
      if (category != null) category.name,
      if (match.round != null) match.round!,
    ].join(' · ');
    // El siguiente se resalta con el color de SU categoría.
    final highlight =
        CategoryColors.parse(category?.color) ?? AppColors.accent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: isNext
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: highlight, width: 1.5),
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: finished ? 0.6 : 1,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CategoryColorStrip(hex: category?.color, width: 6),
                Expanded(child: _content(subtitle, finished, highlight)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(String subtitle, bool finished, Color highlight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          MesaTurnBadge(
            turn: match.mesaOrder!,
            highlighted: isNext,
            highlightColor: highlight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isNext)
                  Text('SIGUIENTE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: highlight,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      )),
                Text(
                  '${match.homePlayerName}  vs  ${match.awayPlayerName}',
                  style: AppTextStyles.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          finished
              ? Text('${match.homeScore} - ${match.awayScore}',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary))
              : Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }
}
