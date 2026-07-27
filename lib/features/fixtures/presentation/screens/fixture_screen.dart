import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:torneo_app/features/tournaments/domain/entities/tournament_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../providers/fixture_provider.dart';
import '../widgets/match_card_widget.dart';

// Import necesario para el provider de jugadores
import '../../../tournaments/presentation/providers/tournament_provider.dart';

class FixtureScreen extends ConsumerWidget {
  final String tournamentId;

  const FixtureScreen({super.key, required this.tournamentId});

  void _confirmDeleteFixture(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar fixture'),
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
              await Supabase.instance.client
                  .from('matches')
                  .delete()
                  .eq('tournament_id', tournamentId);
              ref.read(fixtureProvider(tournamentId).notifier).loadMatches();
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
    final categoriesState = ref.watch(categoriesProvider(tournamentId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixture'),
        actions: [
          if (isAdmin) ...[
            if (fixtureState.matches.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar fixture',
                onPressed: () => _confirmDeleteFixture(context, ref),
              ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Generar fixture',
              onPressed: fixtureState.isGenerating
                  ? null
                  : () => _showGenerateDialog(context, ref, categoriesState),
            ),
          ],
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref
                  .read(fixtureProvider(tournamentId).notifier)
                  .loadMatches(),
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
                    : () => _showGenerateDialog(context, ref, categoriesState),
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
                    : 'Generar fixture'),
              ),
            ),

          // Lista de partidos
          Expanded(
              child: _buildMatchesList(context, ref, fixtureState, isAdmin)),
        ],
      ),
    );
  }

  Widget _buildMatchesList(
      BuildContext context, WidgetRef ref, FixtureState state, bool isAdmin) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando partidos...');
    }

    if (state.matches.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.account_tree_outlined,
        title: 'Sin fixture generado',
        subtitle: isAdmin
            ? 'Genera el fixture para comenzar el torneo'
            : 'El administrador aún no ha generado el fixture',
      );
    }

    final byRound = state.matchesByRound;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: byRound.length,
      itemBuilder: (_, i) {
        final round = byRound.keys.elementAt(i);
        final matches = byRound[round]!;
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
                  onTap: isAdmin && !m.isFinished
                      ? () => _showResultDialog(context, ref, m.id,
                          m.homePlayerName, m.awayPlayerName)
                      : null,
                )),
          ],
        );
      },
    );
  }

  void _showGenerateDialog(
      BuildContext context, WidgetRef ref, CategoriesState categoriesState) {
    if (categoriesState.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero crea categorías para el torneo'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _GenerateFixtureDialog(
        tournamentId: tournamentId,
        categories:
            categoriesState.categories.map((c) => (c.id, c.name)).toList(),
        ref: ref,
      ),
    );
  }

  void _showResultDialog(BuildContext context, WidgetRef ref, String matchId,
      String home, String away) {
    showDialog(
      context: context,
      builder: (_) => _ResultDialog(
        matchId: matchId,
        homePlayerName: home,
        awayPlayerName: away,
        tournamentId: tournamentId,
        ref: ref,
      ),
    );
  }
}

class _GenerateFixtureDialog extends StatefulWidget {
  final String tournamentId;
  final List<(String, String)> categories;
  final WidgetRef ref;

  const _GenerateFixtureDialog({
    required this.tournamentId,
    required this.categories,
    required this.ref,
  });

  @override
  State<_GenerateFixtureDialog> createState() => _GenerateFixtureDialogState();
}

class _GenerateFixtureDialogState extends State<_GenerateFixtureDialog> {
  late String _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categories.first.$1;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generar fixture'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selecciona la categoría:',
              style: AppTextStyles.bodyMedium),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(isDense: true),
            items: widget.categories
                .map((c) => DropdownMenuItem(value: c.$1, child: Text(c.$2)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 8),
          const Text(
            'El fixture se generará automáticamente según la modalidad del torneo.',
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
              : const Text('Generar'),
        ),
      ],
    );
  }

  Future<void> _generate() async {
    setState(() => _isLoading = true);

    // Obtener modalidad del torneo
    final tournaments = widget.ref.read(tournamentsProvider).tournaments;
    final tournament = tournaments.cast<TournamentEntity>().firstWhere(
          (t) => t.id == widget.tournamentId,
          orElse: () => tournaments.cast<TournamentEntity>().first,
        );
    final mode = tournament.mode;

    // Obtener solo jugadores de la categoría seleccionada
    try {
      final enrollments = await Supabase.instance.client
          .from('enrollments')
          .select('player_id, players(id, name)')
          .eq('tournament_id', widget.tournamentId)
          .eq('category_id', _selectedCategory);

      if ((enrollments as List).isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay participantes en esta categoría'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final playerIds =
          enrollments.map((e) => e['player_id'] as String).toList();

      final playerNames = enrollments
          .map((e) => (e['players'] as Map<String, dynamic>)['name'] as String)
          .toList();

      final success = await widget.ref
          .read(fixtureProvider(widget.tournamentId).notifier)
          .generateFixture(
            categoryId: _selectedCategory,
            mode: mode,
            playerIds: playerIds,
            playerNames: playerNames,
          );

      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pop(context);
        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al generar el fixture'),
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
  final String tournamentId;
  final WidgetRef ref;

  const _ResultDialog({
    required this.matchId,
    required this.homePlayerName,
    required this.awayPlayerName,
    required this.tournamentId,
    required this.ref,
  });

  @override
  State<_ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<_ResultDialog> {
  final _homeController = TextEditingController(text: '0');
  final _awayController = TextEditingController(text: '0');
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
      title: const Text('Registrar resultado'),
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
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
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
                      decoration: const InputDecoration(isDense: true),
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
    await widget.ref
        .read(fixtureProvider(widget.tournamentId).notifier)
        .updateResult(
          matchId: widget.matchId,
          homeScore: home,
          awayScore: away,
        );
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }
}
