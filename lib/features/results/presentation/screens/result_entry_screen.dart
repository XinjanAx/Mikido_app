import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart';
import '../providers/result_provider.dart';
import '../widgets/result_form_widget.dart';

class ResultEntryScreen extends ConsumerWidget {
  final String matchId;
  final String tournamentId;

  const ResultEntryScreen({
    super.key,
    required this.matchId,
    required this.tournamentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtureState = ref.watch(fixtureProvider(tournamentId));
    final resultState = ref.watch(resultProvider(tournamentId));

    final match = fixtureState.matches
        .where((m) => m.id == matchId)
        .firstOrNull;

    ref.listen<ResultState>(resultProvider(tournamentId), (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    if (fixtureState.isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    if (match == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar resultado')),
        body: const Center(child: Text('Partido no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar resultado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info del partido
            _MatchInfoCard(match: match),
            const SizedBox(height: 28),

            Text('Marcador final', style: AppTextStyles.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Ingresa el resultado del partido',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey400),
            ),
            const SizedBox(height: 20),

            // Formulario de resultado
            ResultFormWidget(
              homePlayerName: match.homePlayerName,
              awayPlayerName: match.awayPlayerName,
              initialHomeScore: match.homeScore,
              initialAwayScore: match.awayScore,
              isSaving: resultState.isSaving,
              onCancel: () => context.pop(),
              onSave: (homeScore, awayScore, notes) {
                ref.read(resultProvider(tournamentId).notifier).registerResult(
                      matchId: matchId,
                      homePlayerId: match.homePlayerId,
                      awayPlayerId: match.awayPlayerId,
                      homeScore: homeScore,
                      awayScore: awayScore,
                      notes: notes,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchInfoCard extends StatelessWidget {
  final MatchEntity match;

  const _MatchInfoCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sports, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  match.round ?? 'Partido',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary),
                ),
                const Spacer(),
                if (match.isFinished)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Editando resultado',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.info),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.homePlayerName,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('–',
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.grey600)),
                ),
                Expanded(
                  child: Text(
                    match.awayPlayerName,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
