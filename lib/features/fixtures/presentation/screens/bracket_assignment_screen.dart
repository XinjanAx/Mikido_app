import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../../data/services/fixture_generator.dart';
import '../providers/fixture_provider.dart';

/// Arma a mano el cuadro de eliminación simple: toca un participante y
/// luego toca otro para intercambiarlos de posición. La posición en la
/// lista define la cabeza de serie (el de arriba es Sembrado 1, el
/// siguiente Sembrado 2, ...) — el cuadro real se arma con el mismo
/// algoritmo de siembra estándar que el modo aleatorio (FixtureGenerator.
/// standardSeedOrder), así que el rival de cada uno no es necesariamente
/// el de al lado: se muestra explícitamente en cada fila. Si el número
/// de participantes no es potencia de 2, los peor ubicados quedan con
/// "BYE" (pase directo a la siguiente ronda).
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

  /// Rival de cada sembrado (1-indexado) según el mismo algoritmo de
  /// siembra que usa la generación real (FixtureGenerator.
  /// standardSeedOrder) — `null` significa BYE (pase directo). Se
  /// recalcula en cada build a partir del orden actual de [_order], así
  /// que se actualiza solo cuando el admin intercambia participantes.
  Map<int, int?> _computeOpponentBySeed() {
    final n = _order.length;
    final bracketSize = FixtureGenerator.nextPowerOfTwo(n);
    final seedOrder = FixtureGenerator.standardSeedOrder(bracketSize);
    final opponent = <int, int?>{};
    for (var i = 0; i < seedOrder.length; i += 2) {
      final a = seedOrder[i];
      final b = seedOrder[i + 1];
      if (a <= n) opponent[a] = b <= n ? b : null;
      if (b <= n) opponent[b] = a <= n ? a : null;
    }
    return opponent;
  }

  @override
  Widget build(BuildContext context) {
    final n = _order.length;
    final bracketSize = FixtureGenerator.nextPowerOfTwo(n);
    final byes = bracketSize - n;
    final opponentBySeed = _computeOpponentBySeed();

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
                    'para intercambiarlo de posición: la posición define '
                    'la cabeza de serie (arriba = Sembrado 1).'
                  : 'Ahora toca al participante con el que quieres '
                    'intercambiarlo.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              byes > 0
                  ? 'Cuadro de $bracketSize — $byes pase${byes == 1 ? '' : 's'} '
                    'directo${byes == 1 ? '' : 's'} (BYE)'
                  : 'Cuadro de $bracketSize — sin byes',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: _order.length,
              itemBuilder: (context, index) {
                final player = _order[index];
                final seed = index + 1;
                final opponentSeed = opponentBySeed[seed];
                final isBye = opponentSeed == null;
                final isSelected = index == _selectedIndex;

                return Padding(
                  key: ValueKey(player.id),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Card(
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
                      leading: CircleAvatar(child: Text('$seed')),
                      title: Text(player.name),
                      subtitle: Text(
                        isBye
                            ? 'BYE — pasa directo a la siguiente ronda'
                            : 'Rival: ${_order[opponentSeed - 1].name} '
                              '(Sembrado $opponentSeed)',
                        style: isBye
                            ? const TextStyle(
                                color: AppColors.accent,
                                fontStyle: FontStyle.italic)
                            : null,
                      ),
                      trailing: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.swap_horiz,
                        color: isSelected ? AppColors.accent : null,
                      ),
                    ),
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
