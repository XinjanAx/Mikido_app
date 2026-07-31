import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_app/features/tournaments/domain/entities/tournament_entity.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/sync/sync_engine_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../players/presentation/providers/player_provider.dart';
import '../../../standings/domain/entities/standing_entity.dart';
import '../../../standings/presentation/providers/standing_provider.dart';
import '../../data/services/elimination_bracket_service.dart';
import '../../domain/entities/match_entity.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card_widget.dart';
import '../widgets/random_groups_preview_dialog.dart';
import '../widgets/round_advance_confirm_dialog.dart';
import 'bracket_assignment_screen.dart';
import 'group_assignment_screen.dart';

// Import necesario para el provider de jugadores
import '../../../tournaments/presentation/providers/tournament_provider.dart';

class FixtureScreen extends ConsumerWidget {
  final String tournamentId;

  const FixtureScreen({super.key, required this.tournamentId});

  void _confirmDeleteFixture(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar encuentros'),
        content: const Text(
            '¿Eliminar todos los partidos? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(fixtureProvider(tournamentId).notifier).deleteFixture();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixtureState = ref.watch(fixtureProvider(tournamentId));
    final isAdmin = ref.watch(isAdminProvider);
    final tournament = ref.watch(tournamentByIdProvider(tournamentId));
    final mode = tournament?.mode;
    final isElimination = mode == AppConstants.tournamentModeElimination;
    final isTournamentFinished = tournament?.status == AppConstants.statusFinished;
    // En eliminación, que todos los partidos CARGADOS estén terminados no
    // basta: si el cuadro se quedó atascado en una ronda (p. ej. porque
    // advance() nunca generó la siguiente), "todos terminados" sería
    // cierto prematuramente. Exigimos además que exista la ronda Final.
    final isTournamentComplete = fixtureState.matches.isNotEmpty &&
        fixtureState.matches.every((m) => m.isFinished) &&
        (!isElimination || fixtureState.matches.any((m) => m.round == 'Final'));
    final standings =
        ref.watch(standingsStreamProvider(tournamentId)).valueOrNull ?? [];
    final championName =
        _championName(fixtureState.matches, isElimination, standings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuentros'),
        actions: [
          if (isAdmin) ...[
            if (fixtureState.matches.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar encuentros',
                onPressed: () => _confirmDeleteFixture(context, ref),
              ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: fixtureState.matches.isNotEmpty
                  ? 'Ya hay encuentros generados — elimínalos primero para volver a generar'
                  : 'Generar encuentros',
              onPressed: fixtureState.isGenerating ||
                      fixtureState.matches.isNotEmpty
                  ? null
                  : () => _showGenerateDialog(context, ref),
            ),
          ],
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Sincronizar',
              onPressed: () async {
                await ref.read(syncEngineProvider).trySync();
                ref.read(fixtureProvider(tournamentId).notifier).loadMatches();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Botón generar fixture (solo admin)
          if (isAdmin && fixtureState.matches.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: fixtureState.isGenerating
                    ? null
                    : () => _showGenerateDialog(context, ref),
                icon: fixtureState.isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(fixtureState.isGenerating
                    ? 'Generando...'
                    : 'Generar encuentros'),
              ),
            ),

          // Acceso rápido a la vista de resultados: cuadro gráfico en
          // eliminación simple, tabla de posiciones en grupos/liga.
          if (fixtureState.matches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  (isElimination
                          ? RouteConstants.bracket
                          : RouteConstants.standings)
                      .replaceAll(':id', tournamentId),
                ),
                icon: Icon(isElimination
                    ? Icons.account_tree_outlined
                    : Icons.leaderboard_outlined),
                label: Text(isElimination
                    ? 'Ver cuadro de eliminatorias'
                    : 'Ver tabla de posiciones'),
              ),
            ),

          // Finalizar torneo: aparece cuando ya no quedan partidos
          // pendientes, en cualquier modalidad. Antes de esto, cualquier
          // resultado se puede seguir corrigiendo.
          if (isAdmin && isTournamentComplete && !isTournamentFinished)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
                onPressed: () => _confirmFinalize(context, ref),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Finalizar torneo'),
              ),
            ),
          if (isTournamentFinished) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: AppColors.grey400),
                  const SizedBox(width: 6),
                  Text('Torneo finalizado — resultados bloqueados',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400)),
                ],
              ),
            ),
            if (championName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events,
                          color: AppColors.gold, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Campeón',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.grey400)),
                            Text(championName,
                                style: AppTextStyles.headlineMedium
                                    .copyWith(color: AppColors.gold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          // Lista de partidos
          Expanded(
              child: _buildMatchesList(context, ref, fixtureState, isAdmin,
                  isTournamentFinished, isElimination)),
        ],
      ),
    );
  }

  /// Eliminación: gana quien ganó el último partido (mayor número de
  /// partido). Grupos/liga: gana quien encabeza la tabla de posiciones.
  String? _championName(List<MatchEntity> matches, bool isElimination,
      List<StandingEntity> standings) {
    if (isElimination) {
      if (matches.isEmpty) return null;
      // Evitar List.reduce aquí: en runtime `matches` suele ser en
      // realidad un List<MatchModel> (subtipo) expuesto como
      // List<MatchEntity>, y reduce() liga su callback al tipo genérico
      // reificado en runtime, no al estático — con reduce eso rompe con
      // un TypeError de covarianza. Un for manual no tiene ese problema.
      MatchEntity lastMatch = matches.first;
      for (final m in matches) {
        if ((m.matchNumber ?? 0) > (lastMatch.matchNumber ?? 0)) {
          lastMatch = m;
        }
      }
      final winnerId = lastMatch.winner;
      if (winnerId == null) return null;
      return winnerId == lastMatch.homePlayerId
          ? lastMatch.homePlayerName
          : lastMatch.awayPlayerName;
    }
    if (standings.isEmpty) return null;
    return standings.first.playerName;
  }

  void _confirmFinalize(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Finalizar torneo'),
        content: const Text(
            'Ya no se podrán registrar ni corregir resultados. ¿Confirmas que el torneo terminó?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () async {
              Navigator.pop(context);
              final tournament = ref.read(tournamentByIdProvider(tournamentId));
              if (tournament == null) return;
              await ref.read(tournamentsProvider.notifier).updateTournament(
                    TournamentEntity(
                      id: tournament.id,
                      name: tournament.name,
                      mode: tournament.mode,
                      status: AppConstants.statusFinished,
                      description: tournament.description,
                      startDate: tournament.startDate,
                      endDate: tournament.endDate,
                      createdBy: tournament.createdBy,
                      createdAt: tournament.createdAt,
                    ),
                  );
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList(BuildContext context, WidgetRef ref,
      FixtureState state, bool isAdmin, bool isTournamentFinished,
      bool isElimination) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando partidos...');
    }

    if (state.matches.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_tree_outlined,
        title: 'Sin encuentros generados',
        subtitle: isAdmin
            ? 'Genera los encuentros para comenzar el torneo'
            : 'El administrador aún no ha generado los encuentros',
      );
    }

    final byRound = state.matchesByRound;
    // En eliminación las rondas ya vienen en orden cronológico (octavos,
    // cuartos, semifinal, final); se invierten para mostrar primero la
    // ronda más avanzada, sin tener que hacer scroll por las ya jugadas.
    final roundKeys = isElimination
        ? byRound.keys.toList().reversed.toList()
        : byRound.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: roundKeys.length,
      itemBuilder: (_, i) {
        final round = roundKeys[i];
        final matches = byRound[round]!;
        final locked = isElimination && _isRoundLocked(round, byRound);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(round,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.accent,
                  )),
            ),
            ...matches.map((m) => MatchCard(
                  match: m,
                  isAdmin: isAdmin,
                  locked: locked,
                  onTap: isAdmin && !isTournamentFinished && !locked
                      ? () => _showResultDialog(context, ref, m)
                      : null,
                )),
          ],
        );
      },
    );
  }

  /// Una ronda de eliminación queda bloqueada (no editable) en cuanto el
  /// admin confirma el pase a la siguiente ronda y esta ya se generó —
  /// evita corregir un resultado después de que ya se decidió, con esos
  /// jugadores, quién avanza.
  bool _isRoundLocked(String round, Map<String, List<MatchEntity>> byRound) {
    final idx = EliminationBracketService.roundOrder.indexOf(round);
    if (idx == -1 || idx >= EliminationBracketService.roundOrder.length - 1) {
      return false;
    }
    final nextRound = EliminationBracketService.roundOrder[idx + 1];
    final nextMatches = byRound[nextRound];
    return nextMatches != null && nextMatches.isNotEmpty;
  }

  void _showGenerateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _GenerateFixtureDialog(
        tournamentId: tournamentId,
        ref: ref,
      ),
    );
  }

  void _showResultDialog(BuildContext context, WidgetRef ref, MatchEntity match) {
    showDialog(
      context: context,
      builder: (_) => _ResultDialog(
        matchId: match.id,
        homePlayerName: match.homePlayerName,
        awayPlayerName: match.awayPlayerName,
        initialHomeScore: match.homeScore,
        initialAwayScore: match.awayScore,
        tournamentId: tournamentId,
        round: match.round,
        ref: ref,
      ),
    );
  }
}

enum _ArrangementMode { random, manual }

class _GenerateFixtureDialog extends StatefulWidget {
  final String tournamentId;
  final WidgetRef ref;

  const _GenerateFixtureDialog({
    required this.tournamentId,
    required this.ref,
  });

  @override
  State<_GenerateFixtureDialog> createState() => _GenerateFixtureDialogState();
}

class _GenerateFixtureDialogState extends State<_GenerateFixtureDialog> {
  late String _mode;
  int _timesPlayed = 1;
  int _numberOfGroups = 2;
  _ArrangementMode _arrangementMode = _ArrangementMode.random;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tournaments = widget.ref.read(tournamentsProvider).tournaments;
    final tournament = tournaments.cast<TournamentEntity>().firstWhere(
          (t) => t.id == widget.tournamentId,
          orElse: () => tournaments.cast<TournamentEntity>().first,
        );
    _mode = tournament.mode;
  }

  @override
  Widget build(BuildContext context) {
    final isLeague = _mode == AppConstants.tournamentModeLeague;
    final isGroups = _mode == AppConstants.tournamentModeGroups;
    final isElimination = _mode == AppConstants.tournamentModeElimination;
    return AlertDialog(
      title: const Text('Generar encuentros'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLeague) ...[
            const SizedBox(height: 16),
            Text('¿Cuántas veces se enfrenta cada rival?',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _timesPlayed > 1
                      ? () => setState(() => _timesPlayed--)
                      : null,
                ),
                Text('$_timesPlayed', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _timesPlayed < 10
                      ? () => setState(() => _timesPlayed++)
                      : null,
                ),
              ],
            ),
          ],
          if (isGroups) ...[
            const SizedBox(height: 16),
            Text('¿Cómo armar los grupos?',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<_ArrangementMode>(
              segments: const [
                ButtonSegment(
                  value: _ArrangementMode.random,
                  label: Text('Aleatorio'),
                  icon: Icon(Icons.shuffle),
                ),
                ButtonSegment(
                  value: _ArrangementMode.manual,
                  label: Text('Manual'),
                  icon: Icon(Icons.drag_indicator),
                ),
              ],
              selected: {_arrangementMode},
              onSelectionChanged: (s) =>
                  setState(() => _arrangementMode = s.first),
            ),
            const SizedBox(height: 16),
            Text('¿En cuántos grupos?', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _numberOfGroups > 1
                      ? () => setState(() => _numberOfGroups--)
                      : null,
                ),
                Text('$_numberOfGroups', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _numberOfGroups < 20
                      ? () => setState(() => _numberOfGroups++)
                      : null,
                ),
              ],
            ),
          ],
          if (isElimination) ...[
            const SizedBox(height: 16),
            Text('¿Cómo armar el cuadro?', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<_ArrangementMode>(
              segments: const [
                ButtonSegment(
                  value: _ArrangementMode.random,
                  label: Text('Aleatorio'),
                  icon: Icon(Icons.shuffle),
                ),
                ButtonSegment(
                  value: _ArrangementMode.manual,
                  label: Text('Manual'),
                  icon: Icon(Icons.drag_indicator),
                ),
              ],
              selected: {_arrangementMode},
              onSelectionChanged: (s) =>
                  setState(() => _arrangementMode = s.first),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Los encuentros se generarán automáticamente según la modalidad del torneo.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _generate,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.white),
                )
              : Text((isGroups || isElimination) &&
                          _arrangementMode == _ArrangementMode.manual
                      ? 'Continuar'
                      : 'Generar'),
        ),
      ],
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);

    final mode = _mode;
    final navigator = Navigator.of(context);

    try {
      final enrolled = await widget.ref
          .read(playersByTournamentProvider(widget.tournamentId).future);

      if (enrolled.isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay participantes inscritos en este torneo'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Modo grupos: en vez de generar ya, mostrar antes cómo quedaron
      // armados los grupos (manual: arrastrando; aleatorio: vista previa
      // con opción de volver a sortear).
      if (mode == AppConstants.tournamentModeGroups) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        navigator.pop();
        if (_arrangementMode == _ArrangementMode.manual) {
          navigator.push(MaterialPageRoute(
            builder: (_) => GroupAssignmentScreen(
              tournamentId: widget.tournamentId,
              players: enrolled,
              initialGroupCount: _numberOfGroups,
            ),
          ));
        } else {
          showDialog(
            context: navigator.context,
            barrierDismissible: false,
            builder: (_) => RandomGroupsPreviewDialog(
              tournamentId: widget.tournamentId,
              players: enrolled,
              numberOfGroups: _numberOfGroups,
            ),
          );
        }
        return;
      }

      // Modo eliminación manual: armar el cuadro arrastrando participantes
      // antes de generar el fixture.
      if (mode == AppConstants.tournamentModeElimination &&
          _arrangementMode == _ArrangementMode.manual) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        navigator.pop();
        navigator.push(MaterialPageRoute(
          builder: (_) => BracketAssignmentScreen(
            tournamentId: widget.tournamentId,
            players: enrolled,
          ),
        ));
        return;
      }

      final playerIds = enrolled.map((p) => p.id).toList();
      final playerNames = enrolled.map((p) => p.name).toList();

      final success = await widget.ref
          .read(fixtureProvider(widget.tournamentId).notifier)
          .generateFixture(
            mode: mode,
            playerIds: playerIds,
            playerNames: playerNames,
            timesPlayed:
                mode == AppConstants.tournamentModeLeague ? _timesPlayed : 1,
            numberOfGroups:
                mode == AppConstants.tournamentModeGroups ? _numberOfGroups : 0,
          );

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pop(context);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al generar los encuentros'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ResultDialog extends StatefulWidget {
  final String matchId;
  final String homePlayerName;
  final String awayPlayerName;
  final int? initialHomeScore;
  final int? initialAwayScore;
  final String tournamentId;
  final String? round;
  final WidgetRef ref;

  const _ResultDialog({
    required this.matchId,
    required this.homePlayerName,
    required this.awayPlayerName,
    this.initialHomeScore,
    this.initialAwayScore,
    required this.tournamentId,
    this.round,
    required this.ref,
  });

  bool get _isEdit => initialHomeScore != null || initialAwayScore != null;

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog> {
  late final _homeController =
      TextEditingController(text: widget.initialHomeScore?.toString() ?? '');
  late final _awayController =
      TextEditingController(text: widget.initialAwayScore?.toString() ?? '');
  bool _isSaving = false;

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._isEdit ? 'Corregir resultado' : 'Registrar resultado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(widget.homePlayerName,
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _homeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.scoreDisplay,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '0',
                        hintStyle: AppTextStyles.scoreDisplay
                            .copyWith(color: AppColors.grey600),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('vs', style: AppTextStyles.bodyMedium),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(widget.awayPlayerName,
                        style: AppTextStyles.titleMedium,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _awayController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.scoreDisplay,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '0',
                        hintStyle: AppTextStyles.scoreDisplay
                            .copyWith(color: AppColors.grey600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.white),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final home = int.tryParse(_homeController.text) ?? 0;
    final away = int.tryParse(_awayController.text) ?? 0;
    setState(() => _isSaving = true);
    final ok = await widget.ref
        .read(fixtureProvider(widget.tournamentId).notifier)
        .updateResult(
          matchId: widget.matchId,
          homeScore: home,
          awayScore: away,
        );

    if (ok && widget.round != null && mounted) {
      final tournament =
          widget.ref.read(tournamentByIdProvider(widget.tournamentId));
      if (tournament?.mode == AppConstants.tournamentModeElimination) {
        final bracket = widget.ref.read(eliminationBracketServiceProvider);
        final pending = await bracket.checkRoundComplete(
          tournamentId: widget.tournamentId,
          completedRound: widget.round!,
        );
        if (pending != null && mounted) {
          final confirmed =
              await showRoundAdvanceConfirmDialog(context, pending);
          if (confirmed) {
            await bracket.generateNextRound(pending);
            widget.ref
                .read(fixtureProvider(widget.tournamentId).notifier)
                .loadMatches();
          }
        }
      }
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }
}
