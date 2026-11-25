import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:torneo_app/features/tournaments/domain/entities/tournament_entity.dart';
import 'package:torneo_app/features/tournaments/presentation/widgets/category_color_widgets.dart';
import 'package:torneo_app/features/fixtures/presentation/services/match_result_flow.dart';
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
import '../../../standings/domain/services/tiebreak_detector.dart';
import '../../../standings/presentation/providers/standing_provider.dart';
import '../../../standings/presentation/widgets/tiebreak_resolution_dialog.dart';
import '../../data/services/elimination_bracket_service.dart';
import '../../domain/entities/match_entity.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card_widget.dart';
import '../widgets/random_groups_preview_dialog.dart';
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
              await ref
                  .read(fixtureProvider(tournamentId).notifier)
                  .deleteFixture();
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
    final isGroups = mode == AppConstants.tournamentModeGroups;
    final isTournamentFinished =
        tournament?.status == AppConstants.statusFinished;
    // El partido por el 3er puesto se evalúa aparte del resto del cuadro:
    // no se exige para considerar terminada la llave principal (si no,
    // "Finalizar torneo" desaparecería sin explicación apenas se genera),
    // pero si existe y sigue pendiente, bloquea igual la finalización más
    // abajo — con un aviso explícito en vez de ocultar el botón en
    // silencio.
    final thirdPlaceMatch = fixtureState.matches
        .where((m) => m.round == 'Tercer puesto')
        .firstOrNull;
    final mainBracketMatches =
        fixtureState.matches.where((m) => m.round != 'Tercer puesto').toList();
    // En eliminación, que todos los partidos CARGADOS estén terminados no
    // basta: si el cuadro se quedó atascado en una ronda (p. ej. porque
    // advance() nunca generó la siguiente), "todos terminados" sería
    // cierto prematuramente. Exigimos además que exista la ronda Final.
    final isMainBracketComplete = mainBracketMatches.isNotEmpty &&
        mainBracketMatches.every((m) => m.isFinished) &&
        (!isElimination || mainBracketMatches.any((m) => m.round == 'Final'));
    final needsThirdPlace =
        isElimination && thirdPlaceMatch != null && !thirdPlaceMatch.isFinished;
    final isTournamentComplete = isMainBracketComplete && !needsThirdPlace;
    final standings =
        ref.watch(standingsStreamProvider(tournamentId)).valueOrNull ?? [];
    final champion = _champion(fixtureState.matches, isElimination, standings);
    final championName = champion?.name;
    final championGuild = champion == null
        ? null
        : ref.watch(playerGuildsProvider)[champion.id];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: CategoryHeaderGradient(tournamentId: tournamentId),
        title: Text(tournament != null
            ? 'Encuentros - ${tournament.name}'
            : 'Encuentros'),
        actions: [
          if (isAdmin) ...[
            if (fixtureState.matches.isNotEmpty && !isTournamentFinished)
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
              onPressed:
                  fixtureState.isGenerating || fixtureState.matches.isNotEmpty
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
          // eliminación simple, tabla de posiciones en grupos/liga. (El
          // botón de "carga rápida" se quitó: los resultados se registran
          // en Mesa en vivo.)
          if (fixtureState.matches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
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
            ),

          // Aviso bloqueante: la llave principal ya terminó, pero el
          // partido por el 3er puesto sigue pendiente — no se puede
          // finalizar el torneo hasta que también se juegue.
          if (isAdmin &&
              isMainBracketComplete &&
              needsThirdPlace &&
              !isTournamentFinished)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_outlined,
                        color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Falta definir el partido por el tercer puesto '
                        '(${thirdPlaceMatch.homePlayerName} vs '
                        '${thirdPlaceMatch.awayPlayerName}) antes de poder '
                        'finalizar la categoría.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
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
                onPressed: () => _confirmFinalize(context, ref, standings,
                    isGroups, isElimination, fixtureState.matches),
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Finalizar categoría'),
              ),
            ),
          if (isTournamentFinished) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppColors.grey400),
                  const SizedBox(width: 6),
                  Text('Categoría finalizada — resultados bloqueados',
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
                            // Gremio completo, más chico y en gris.
                            if (championGuild != null)
                              Text(championGuild,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.grey400)),
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

  /// Eliminación: gana quien ganó la Final. Grupos/liga: gana quien
  /// encabeza la tabla de posiciones.
  ({String id, String name})? _champion(List<MatchEntity> matches,
      bool isElimination, List<StandingEntity> standings) {
    if (isElimination) {
      // Se busca la ronda "Final" explícitamente en vez de asumir que es
      // el partido con mayor `matchNumber`: el partido por el 3er puesto
      // se genera después de la Final (número más alto), así que ese
      // supuesto elegiría por error al ganador del 3er puesto como
      // "Campeón".
      MatchEntity? finalMatch;
      for (final m in matches) {
        if (m.round == 'Final') finalMatch = m;
      }
      if (finalMatch == null) return null;
      final winnerId = finalMatch.winner;
      if (winnerId == null) return null;
      return winnerId == finalMatch.homePlayerId
          ? (id: finalMatch.homePlayerId, name: finalMatch.homePlayerName)
          : (id: finalMatch.awayPlayerId, name: finalMatch.awayPlayerName);
    }
    if (standings.isEmpty) return null;
    return (id: standings.first.playerId, name: standings.first.playerName);
  }

  /// Si no hay empates sin resolver, el flujo de siempre (confirmar y
  /// finalizar). Si los hay — en liga comparando a todos, en grupos solo
  /// dentro de cada grupo —, primero hay que resolverlos a mano: el propio
  /// botón "Guardar y finalizar torneo" del diálogo de empates ya cumple el
  /// rol de confirmación, así que no se apila un segundo diálogo.
  ///
  /// En eliminación directa esta detección NUNCA corre: comparar puntos
  /// (PJ/PG/PP) entre jugadores que jamás se enfrentaron no tiene sentido
  /// ahí — dos eliminados con el mismo marcador en partidos distintos no
  /// están "empatados" en ningún sentido competitivo real, y antes de este
  /// fix disparaban el diálogo de resolución de empates propio de liga.
  Future<void> _confirmFinalize(
    BuildContext context,
    WidgetRef ref,
    List<StandingEntity> standings,
    bool isGroups,
    bool isElimination,
    List<MatchEntity> matches,
  ) async {
    Map<String, String>? groupOf;
    if (isGroups) {
      groupOf = {};
      for (final m in matches) {
        final round = m.round;
        if (round == null || !round.startsWith('Grupo')) continue;
        groupOf[m.homePlayerId] = round;
        if (m.awayPlayerId != m.homePlayerId) groupOf[m.awayPlayerId] = round;
      }
    }
    final tied = isElimination
        ? const <TiedGroup>[]
        : detectTiedGroups(standings, groupOf: groupOf);

    if (tied.isEmpty) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Finalizar categoría'),
          content: const Text(
              'Ya no se podrán registrar ni corregir resultados. ¿Confirmas que la categoría terminó?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () async {
                Navigator.pop(context);
                await _finalizeTournament(ref);
              },
              child: const Text('Finalizar'),
            ),
          ],
        ),
      );
      return;
    }

    final resolution = await showTiebreakResolutionDialog(context, tied);
    if (resolution == null) return;

    for (final entry in resolution.entries) {
      final standing = standings.firstWhere((s) => s.id == entry.key);
      await ref.read(saveManualRankUseCaseProvider)(standing, entry.value);
    }
    await _finalizeTournament(ref);
  }

  Future<void> _finalizeTournament(WidgetRef ref) async {
    final tournament = ref.read(tournamentByIdProvider(tournamentId));
    if (tournament == null) return;
    await ref.read(tournamentsProvider.notifier).updateTournament(
          tournament.copyWith(status: AppConstants.statusFinished),
        );
  }

  /// Un encuentro pendiente de una categoría con mesa se registra en Mesa en
  /// vivo, que respeta el orden de la mesa. Aquí solo se avisa y se ofrece
  /// ir allá.
  ///
  /// Es un diálogo y no un SnackBar a propósito: un SnackBar con acción ya
  /// no se cierra solo, y como vive en el ScaffoldMessenger de toda la app
  /// seguía visible al volver atrás, con un "IR" que navegaba desde esta
  /// pantalla ya cerrada (no hacía nada).
  Future<void> _goToLiveHint(BuildContext context, String mesaId) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.tv, color: AppColors.accent),
        title: const Text('Se registra en Mesa en vivo'),
        content: const Text(
          'Los resultados se registran en Mesa en vivo, en el orden de la '
          'mesa. Aquí solo se corrigen encuentros ya jugados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ir a Mesa en vivo'),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      context.push(RouteConstants.mesaLive.replaceAll(':id', mesaId));
    }
  }

  Widget _buildMatchesList(
      BuildContext context,
      WidgetRef ref,
      FixtureState state,
      bool isAdmin,
      bool isTournamentFinished,
      bool isElimination) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando partidos...');
    }

    if (state.matches.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_tree_outlined,
        title: 'Sin encuentros generados',
        subtitle: isAdmin
            ? 'Genera los encuentros para comenzar la categoría'
            : 'El administrador aún no ha generado los encuentros',
      );
    }

    final mesaId = ref.watch(tournamentByIdProvider(tournamentId))?.mesaId;
    final byRound = state.matchesByRound;
    // En eliminación se muestra primero la ronda más avanzada (Final
    // arriba de todo), sin tener que hacer scroll por las ya jugadas. El
    // 3er puesto no tiene lugar propio en ese orden cronológico — se
    // intercala justo debajo de la Final a mano.
    final roundKeys = isElimination
        ? _orderedEliminationRoundKeys(byRound.keys)
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
                  registeredInLive: mesaId != null && !m.isFinished,
                  onTap: !isAdmin || isTournamentFinished || locked
                      ? null
                      // Con mesa, los pendientes se registran en Mesa en
                      // vivo (en orden); aquí solo se corrigen los jugados.
                      : (mesaId != null && !m.isFinished)
                          ? () => _goToLiveHint(context, mesaId)
                          : () => _showResultDialog(context, ref, m),
                )),
          ],
        );
      },
    );
  }

  /// Ordena las rondas de eliminación de la más avanzada a la más
  /// temprana (Final primero), intercalando "Tercer puesto" justo debajo
  /// de la Final — no está en `roundOrder` porque no forma parte de la
  /// progresión del cuadro, así que necesita su propio criterio de orden.
  List<String> _orderedEliminationRoundKeys(Iterable<String> keys) {
    const order = EliminationBracketService.roundOrder;
    double rankOf(String round) {
      if (round == 'Tercer puesto') {
        return order.indexOf('Final') - 0.5;
      }
      final idx = order.indexOf(round);
      return idx == -1 ? -1 : idx.toDouble();
    }

    return keys.toList()..sort((a, b) => rankOf(b).compareTo(rankOf(a)));
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

  void _showResultDialog(
      BuildContext context, WidgetRef ref, MatchEntity match) {
    showDialog(
      context: context,
      builder: (_) => _ResultDialog(
        match: match,
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
            Text('¿Cómo armar los grupos?', style: AppTextStyles.bodyMedium),
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
            'Los encuentros se generarán automáticamente según la modalidad de la categoría.',
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

  Future<bool?> _confirmThreePlayerElimination() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: AppColors.warning, size: 36),
        title: const Text('Solo hay 3 participantes'),
        content: const Text(
          'Con 3 participantes se recomienda cambiar la modalidad de la '
          'categoría a Liga (todos contra todos).\n\n'
          'En eliminación simple uno de los tres pasa directo a la final '
          'sin jugar la semifinal, y no hay partido por el 3er puesto (el '
          'perdedor de la semifinal queda tercero).\n\n'
          '¿Generar igual en eliminación simple?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Generar igual'),
          ),
        ],
      ),
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
              content: Text('No hay participantes inscritos en esta categoría'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Eliminación simple con solo 3 participantes: se recomienda liga
      // (todos contra todos). Se puede continuar igual si el admin insiste.
      if (mode == AppConstants.tournamentModeElimination &&
          enrolled.length == 3) {
        final proceed = await _confirmThreePlayerElimination();
        if (proceed != true) {
          if (mounted) setState(() => _isLoading = false);
          return;
        }
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

/// Recorta el marcador a [AppConstants.maxMatchScore] mientras se escribe
/// — un partido no puede terminar con un resultado absurdo por un dedo
/// que se resbala en el teclado numérico.
class _MaxScoreInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null || value <= AppConstants.maxMatchScore) return newValue;
    final clamped = AppConstants.maxMatchScore.toString();
    return TextEditingValue(
      text: clamped,
      selection: TextSelection.collapsed(offset: clamped.length),
    );
  }
}

class _ResultDialog extends StatefulWidget {
  final MatchEntity match;
  final String matchId;
  final String homePlayerName;
  final String awayPlayerName;
  final int? initialHomeScore;
  final int? initialAwayScore;
  final String tournamentId;
  final String? round;
  final WidgetRef ref;

  const _ResultDialog({
    required this.match,
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
  static final List<TextInputFormatter> _scoreInputFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    _MaxScoreInputFormatter(),
  ];
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
      title:
          Text(widget._isEdit ? 'Corregir resultado' : 'Registrar resultado'),
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
                      inputFormatters: _scoreInputFormatters,
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
                      inputFormatters: _scoreInputFormatters,
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

    // Mismas reglas que Mesa en vivo (sin empates en eliminación,
    // confirmación de avance de ronda): ver match_result_flow.dart.
    setState(() => _isSaving = true);
    final ok = await submitMatchResult(
      context: context,
      ref: widget.ref,
      match: widget.match,
      homeScore: home,
      awayScore: away,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) Navigator.pop(context);
  }
}
