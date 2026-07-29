import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../providers/fixture_provider.dart';

/// Arma a mano el cuadro de eliminación simple: toca un participante y
/// luego toca otro para intercambiarlos de posición. Cada 2 en fila
/// forman un partido de la primera ronda (posiciones 1-2, 3-4, ...);
/// si sobra uno al final, pasa con bye.
class BracketAssignmentScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  final List<PlayerEntity> players;

  const BracketAssignmentScreen({
    super.key,
    required this.tournamentId,
    required this.players,
  });

  @override
  ConsumerState<BracketAssignmentScreen> createState() =>
      _BracketAssignmentScreenState();
}

class _BracketAssignmentScreenState
    extends ConsumerState<BracketAssignmentScreen> {
  late List<PlayerEntity> _order;
  int? _selectedIndex;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _order = List<PlayerEntity>.from(widget.players);
  }

  void _shuffle() {
    setState(() {
      _order.shuffle();
      _selectedIndex = null;
    });
  }

  void _onTapPlayer(int index) {
    setState(() {
      if (_selectedIndex == null) {
        _selectedIndex = index;
      } else if (_selectedIndex == index) {
        _selectedIndex = null;
      } else {
        final temp = _order[_selectedIndex!];
        _order[_selectedIndex!] = _order[index];
        _order[index] = temp;
        _selectedIndex = null;
      }
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
        SnackBar(content: Text(error ?? 'Error al generar los encuentros')),
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
              _selectedIndex == null
                  ? 'Toca un participante para elegirlo y luego toca otro '
                    'para intercambiarlos de posición.'
                  : 'Ahora toca al participante con el que quieres '
                    'intercambiarlo.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: _order.length,
              itemBuilder: (context, index) {
                final player = _order[index];
                final isBye =
                    index == _order.length - 1 && _order.length.isOdd;
                final matchLabel = isBye
                    ? 'BYE — pasa directo'
                    : (index.isEven ? 'Partido ${index ~/ 2 + 1}' : null);
                final isSelected = index == _selectedIndex;

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
                        color: isSelected
                            ? AppColors.accent.withOpacity(0.12)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.accent
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          onTap: () => _onTapPlayer(index),
                          leading: CircleAvatar(
                            child: Text(player.name.isNotEmpty
                                ? player.name[0].toUpperCase()
                                : '?'),
                          ),
                          title: Text(player.name),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.swap_horiz,
                            color: isSelected ? AppColors.accent : null,
                          ),
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
        label: Text(_isGenerating ? 'Generando...' : 'Generar encuentros'),
      ),
    );
  }
}
