import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../tournaments/presentation/providers/tournament_provider.dart';
import '../providers/fixture_provider.dart';
import '../widgets/bracket_widget.dart';
import '../widgets/group_table_widget.dart';

/// Vista gráfica del fixture: cuadro eliminatorio, tablas por grupo o
/// jornadas de liga, según la modalidad del torneo (se obtiene sola, no
/// hace falta pasarla).
class BracketScreen extends ConsumerWidget {
  final String tournamentId;

  const BracketScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtureState = ref.watch(fixtureProvider(tournamentId));
    final tournamentAsync = ref.watch(tournamentByIdProvider(tournamentId));
    final mode = tournamentAsync.valueOrNull?.mode;

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle(mode)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(fixtureProvider(tournamentId).notifier).loadMatches(),
          ),
        ],
      ),
      body: mode == null
          ? const LoadingWidget()
          : _buildBody(fixtureState, mode),
    );
  }

  String _screenTitle(String? mode) {
    switch (mode) {
      case AppConstants.tournamentModeElimination:
        return 'Cuadro eliminatorio';
      case AppConstants.tournamentModeGroups:
        return 'Tablas de grupo';
      default:
        return 'Jornadas';
    }
  }

  Widget _buildBody(FixtureState state, String mode) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando fixture...');
    }

    if (state.matches.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.account_tree_outlined,
        title: 'Sin fixture generado',
        subtitle: 'Ve a la pantalla de Fixture para generarlo',
      );
    }

    switch (mode) {
      case AppConstants.tournamentModeElimination:
        return BracketWidget(matchesByRound: state.matchesByRound);

      case AppConstants.tournamentModeGroups:
        return _GroupsView(matchesByRound: state.matchesByRound);

      case AppConstants.tournamentModeLeague:
        return _LeagueView(matchesByRound: state.matchesByRound);

      default:
        return BracketWidget(matchesByRound: state.matchesByRound);
    }
  }
}

// ─── Vista de grupos ────────────────────────────────────────────────

class _GroupsView extends StatelessWidget {
  final Map<String, List<dynamic>> matchesByRound;

  const _GroupsView({required this.matchesByRound});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Tablas'),
              Tab(text: 'Partidos'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: Tablas por grupo
                ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  children: matchesByRound.entries.map((entry) {
                    return GroupTableWidget(
                      groupName: entry.key,
                      matches: List.from(entry.value),
                    );
                  }).toList(),
                ),

                // Tab 2: Partidos por grupo
                ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  children: matchesByRound.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      ...entry.value.map((m) => _SimpleMatchTile(match: m)),
                    ];
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vista de liga ─────────────────────────────────────────────────

class _LeagueView extends StatelessWidget {
  final Map<String, List<dynamic>> matchesByRound;

  const _LeagueView({required this.matchesByRound});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: matchesByRound.entries.expand((entry) {
        return [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              entry.key,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ...entry.value.map((m) => _SimpleMatchTile(match: m)),
        ];
      }).toList(),
    );
  }
}

// ─── Tile simple de partido ─────────────────────────────────────────

class _SimpleMatchTile extends StatelessWidget {
  final dynamic match;

  const _SimpleMatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final finished = match.isFinished as bool;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                match.homePlayerName as String,
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: finished
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: finished
                      ? AppColors.primary.withOpacity(0.4)
                      : AppColors.border,
                ),
              ),
              child: Text(
                finished
                    ? '${match.homeScore} - ${match.awayScore}'
                    : 'vs',
                style: TextStyle(
                  color:
                      finished ? AppColors.primary : AppColors.grey400,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                match.awayPlayerName as String,
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
