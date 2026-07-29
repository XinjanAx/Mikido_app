import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../providers/fixture_provider.dart';

/// Arma a mano el cuadro de eliminación simple: arrastra participantes
/// para reordenarlos. Cada 2 en fila forman un partido de la primera
/// ronda (posiciones 1-2, 3-4, ...); si sobra uno al final, pasa con bye.
class BracketAssignmentScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  final String categoryId;
  final List<PlayerEntity> players;

  const BracketAssignmentScreen({
    super.key,
    required this.tournamentId,
    required this.categoryId,
    required this.players,
  });

  @override
  ConsumerState<BracketAssignmentScreen> createState() =>
      _BracketAssignmentScreenState();
}

class _BracketAssignmentScreenState
    extends ConsumerState<BracketAssignmentScreen> {
  late List<PlayerEntity> _order;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _order = List<PlayerEntity>.from(widget.players);
  }

  void _shuffle() {
    setState(() => _order.shuffle());
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
  }

  Future<void> _generate() async {
    setState(() => _isGenerating = true);

    final manualOrder = _order.map((p) => p.id).toList();
    final playerIds = widget.players.map((p) => p.id).toList();
    final playerNames = widget.players.map((p) => p.name).toList();

    final success = await ref
        .read(fixtureProvider(widget.tournamentId).notifier)
        .generateFixture(
          categoryId: widget.categoryId,
          mode: AppConstants.tournamentModeElimination,
          playerIds: playerIds,
          playerNames: playerNames,
          manualBracketOrder: manualOrder,
        );

    if (!mounted) return;
    setState(() => _isGenerating = false);
    if (success) {
      Navigator.of(context).pop();
    } else {
      final error = ref.read(fixtureProvider(widget.tournamentId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Error al generar el fixture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Armar cuadro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Mezclar',
            onPressed: _shuffle,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Mantén presionado y arrastra para ordenar. Cada 2 en fila '
              'forman un partido de la primera ronda.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: _order.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final player = _order[index];
                final isBye =
                    index == _order.length - 1 && _order.length.isOdd;
                final matchLabel = isBye
                    ? 'BYE — pasa directo'
                    : (index.isEven ? 'Partido ${index ~/ 2 + 1}' : null);

                return Padding(
                  key: ValueKey(player.id),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (matchLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 6),
                          child: Text(matchLabel,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: AppColors.accent)),
                        ),
                      Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(player.name.isNotEmpty
                                ? player.name[0].toUpperCase()
                                : '?'),
                          ),
                          title: Text(player.name),
                          trailing: const Icon(Icons.drag_handle),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isGenerating ? null : _generate,
        icon: _isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? 'Generando...' : 'Generar fixture'),
      ),
    );
  }
}
