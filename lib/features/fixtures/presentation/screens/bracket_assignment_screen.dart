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

  /// Pares de sembrados según el mismo algoritmo de siembra que usa la
  /// generación real (FixtureGenerator.standardSeedOrder). Se descartan
  /// los pares donde NINGÚN lado tiene un participante real (pasa cuando
  /// hay muchos más cupos del cuadro que participantes) — esos no
  /// representan ningún partido. Se recalcula en cada build a partir del
  /// orden actual de [_order], así se actualiza solo cuando el admin
  /// intercambia participantes.
  List<({int seedA, int seedB})> _computePairs() {
    final n = _order.length;
    final bracketSize = FixtureGenerator.nextPowerOfTwo(n);
    final seedOrder = FixtureGenerator.standardSeedOrder(bracketSize);
    final pairs = <({int seedA, int seedB})>[];
    for (var i = 0; i < seedOrder.length; i += 2) {
      final a = seedOrder[i];
      final b = seedOrder[i + 1];
      if (a <= n || b <= n) pairs.add((seedA: a, seedB: b));
    }
    return pairs;
  }

  @override
  Widget build(BuildContext context) {
    final n = _order.length;
    final bracketSize = FixtureGenerator.nextPowerOfTwo(n);
    final byes = bracketSize - n;
    final pairs = _computePairs();

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
                    'para intercambiarlo de posición entre partidos.'
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
              itemCount: pairs.length,
              itemBuilder: (context, i) {
                final pair = pairs[i];
                final indexA = pair.seedA - 1;
                final indexB = pair.seedB - 1;
                final hasA = indexA < n;
                final hasB = indexB < n;

                return _PairCard(
                  matchNumber: i + 1,
                  seedA: pair.seedA,
                  playerA: hasA ? _order[indexA] : null,
                  isSelectedA: hasA && indexA == _selectedIndex,
                  onTapA: hasA ? () => _onTapPlayer(indexA) : null,
                  seedB: pair.seedB,
                  playerB: hasB ? _order[indexB] : null,
                  isSelectedB: hasB && indexB == _selectedIndex,
                  onTapB: hasB ? () => _onTapPlayer(indexB) : null,
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

/// Un partido del cuadro: dos casillas de sembrado apiladas, cada una
/// tocable para elegir/intercambiar. Si un lado no tiene participante
/// real (el otro sembrado avanza por BYE), se muestra atenuado y no se
/// puede tocar.
class _PairCard extends StatelessWidget {
  final int matchNumber;
  final int seedA;
  final PlayerEntity? playerA;
  final bool isSelectedA;
  final VoidCallback? onTapA;
  final int seedB;
  final PlayerEntity? playerB;
  final bool isSelectedB;
  final VoidCallback? onTapB;

  const _PairCard({
    required this.matchNumber,
    required this.seedA,
    required this.playerA,
    required this.isSelectedA,
    required this.onTapA,
    required this.seedB,
    required this.playerB,
    required this.isSelectedB,
    required this.onTapB,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'Partido $matchNumber',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey400),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                _SeedRow(
                  seed: seedA,
                  player: playerA,
                  isSelected: isSelectedA,
                  onTap: onTapA,
                ),
                const Divider(height: 1),
                _SeedRow(
                  seed: seedB,
                  player: playerB,
                  isSelected: isSelectedB,
                  onTap: onTapB,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeedRow extends StatelessWidget {
  final int seed;
  final PlayerEntity? player;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SeedRow({
    required this.seed,
    required this.player,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBye = player == null;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.accent.withOpacity(0.12) : null,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor:
                  isBye ? AppColors.surfaceVariant : AppColors.primary,
              child: Text('$seed', style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isBye ? 'BYE — pasa directo' : player!.nameWithAcronym,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isBye
                    ? AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey400,
                        fontStyle: FontStyle.italic)
                    : AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (!isBye)
              Icon(
                isSelected ? Icons.check_circle : Icons.swap_horiz,
                size: 18,
                color: isSelected ? AppColors.accent : AppColors.grey600,
              ),
          ],
        ),
      ),
    );
  }
}
