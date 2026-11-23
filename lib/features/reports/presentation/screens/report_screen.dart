import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torneo_app/features/tournaments/presentation/widgets/category_color_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../fixtures/domain/entities/match_entity.dart';
import '../../../fixtures/presentation/providers/fixture_provider.dart';
import '../../../standings/presentation/providers/standing_provider.dart';
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../../domain/entities/report_params.dart';
import '../providers/report_provider.dart';

class ReportScreen extends ConsumerWidget {
  final String tournamentId;

  const ReportScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);
    final tournament = ref.watch(tournamentsProvider).tournaments
        .where((t) => t.id == tournamentId)
        .firstOrNull;

    ref.listen<ReportState>(reportProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
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

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: CategoryHeaderGradient(tournamentId: tournamentId),
        title: const Text('Reportes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tournament != null) ...[
              Text(tournament.name, style: AppTextStyles.headlineMedium),
              Text(tournament.modeLabel,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.grey400)),
              const SizedBox(height: 32),
            ],
            Text('Exportar información', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Genera reportes con las posiciones y resultados de la categoría.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.grey400),
            ),
            const SizedBox(height: 28),
            _ExportCard(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Exportar PDF',
              subtitle: 'Tabla de posiciones y resultados en PDF',
              color: AppColors.error,
              isLoading: reportState.isGeneratingPdf,
              onTap: () => _export(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    if (ref.read(reportProvider).isGeneratingPdf) return;
    ref.read(reportProvider.notifier).startGenerating();

    final tournament = ref.read(tournamentsProvider).tournaments
        .firstWhere((t) => t.id == tournamentId);
    final standings = ref
            .read(standingsStreamProvider(tournamentId))
            .valueOrNull ??
        [];
    // Se pide directo al usecase (no al fixtureProvider ya instanciado) para
    // garantizar la lista completa y fresca de TODAS las rondas — si el
    // provider de fixtures no se había abierto antes en esta navegación,
    // leer su estado podía traer una lista vacía o desactualizada.
    final matchesResult =
        await ref.read(getMatchesUseCaseProvider)(tournamentId);
    final matches = matchesResult.fold((_) => <MatchEntity>[], (list) => list);

    // En modo grupos, se particiona la tabla de posiciones REAL (ya
    // ordenada con el mismo criterio que la pantalla de posiciones:
    // puntos, diferencia de gol, desempate manual) en vez de recalcularla
    // desde los partidos — así el PDF respeta cualquier empate que el
    // admin ya haya resuelto a mano.
    Map<String, List<Map<String, dynamic>>>? groupedStandings;
    if (tournament.mode == AppConstants.tournamentModeGroups) {
      final groupOf = <String, String>{};
      for (final m in matches) {
        final round = m.round;
        if (round == null || !round.startsWith('Grupo')) continue;
        groupOf[m.homePlayerId] = round;
        if (m.awayPlayerId != m.homePlayerId) groupOf[m.awayPlayerId] = round;
      }
      groupedStandings = {};
      for (final s in standings) {
        final group = groupOf[s.playerId] ?? 'Sin grupo';
        groupedStandings.putIfAbsent(group, () => []).add({
          'player_name': s.playerName,
          'played': s.played,
          'won': s.won,
          'lost': s.lost,
          'goals_for': s.goalsFor,
          'goals_against': s.goalsAgainst,
          'points': s.points,
        });
      }
    }

    final params = ReportParams(
      tournamentName: tournament.name,
      category: tournament.modeLabel,
      mode: tournament.mode,
      standings: standings
          .map((s) => {
                'player_name': s.playerName,
                'played': s.played,
                'won': s.won,
                'lost': s.lost,
                'goals_for': s.goalsFor,
                'goals_against': s.goalsAgainst,
                'points': s.points,
              })
          .toList(),
      matches: matches
          .map((m) => {
                'home': m.homePlayerName,
                'away': m.awayPlayerName,
                'home_score': m.homeScore ?? 0,
                'away_score': m.awayScore ?? 0,
                'status': m.status,
                'round': m.round,
              })
          .toList(),
      groupedStandings: groupedStandings,
    );

    if (!context.mounted) return;
    await ref.read(reportProvider.notifier).exportPdf(params);
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: color,
                        ),
                      )
                    : Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.grey400)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.grey600),
            ],
          ),
        ),
      ),
    );
  }
}
