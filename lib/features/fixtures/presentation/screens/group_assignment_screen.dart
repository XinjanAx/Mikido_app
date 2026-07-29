import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../providers/fixture_provider.dart';

/// Pantalla para armar los grupos a mano: arrastra cada participante desde
/// "Sin asignar" hacia el grupo que quieras. Al terminar, genera el fixture
/// usando exactamente esa agrupación (en vez de una automática/aleatoria).
class GroupAssignmentScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  final List<PlayerEntity> players;
  final int initialGroupCount;

  const GroupAssignmentScreen({
    super.key,
    required this.tournamentId,
    required this.players,
    required this.initialGroupCount,
  });

  @override
  ConsumerState<GroupAssignmentScreen> createState() =>
      _GroupAssignmentScreenState();
}

class _GroupAssignmentScreenState
    extends ConsumerState<GroupAssignmentScreen> {
  static const _unassigned = '';

  late List<String> _groupLabels;
  late Map<String, List<PlayerEntity>> _groups;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _groupLabels =
        List.generate(widget.initialGroupCount, (i) => String.fromCharCode(65 + i));
    _groups = {
      _unassigned: List<PlayerEntity>.from(widget.players),
      for (final label in _groupLabels) label: <PlayerEntity>[],
    };
  }

  void _movePlayer(PlayerEntity player, String targetLabel) {
    setState(() {
      for (final list in _groups.values) {
        list.removeWhere((p) => p.id == player.id);
      }
      _groups[targetLabel]!.add(player);
    });
  }

  void _addGroup() {
    if (_groupLabels.length >= 20) return;
    setState(() {
      final label = String.fromCharCode(65 + _groupLabels.length);
      _groupLabels.add(label);
      _groups[label] = [];
    });
  }

  void _removeLastGroup() {
    if (_groupLabels.length <= 1) return;
    setState(() {
      final label = _groupLabels.removeLast();
      final freed = _groups.remove(label) ?? [];
      _groups[_unassigned]!.addAll(freed);
    });
  }

  void _shuffleRemaining() {
    setState(() {
      final pending = List<PlayerEntity>.from(_groups[_unassigned]!)..shuffle();
      _groups[_unassigned]!.clear();
      for (final player in pending) {
        // Siempre cae en el grupo con menos jugadores hasta ahora.
        final label = _groupLabels
            .reduce((a, b) => _groups[a]!.length <= _groups[b]!.length ? a : b);
        _groups[label]!.add(player);
      }
    });
  }

  Future<void> _generate() async {
    final unassigned = _groups[_unassigned]!;
    if (unassigned.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asigna a todos los participantes antes de generar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final manualGroups =
        _groupLabels.map((l) => _groups[l]!.map((p) => p.id).toList()).toList();
    final playerIds = widget.players.map((p) => p.id).toList();
    final playerNames = widget.players.map((p) => p.name).toList();

    final success = await ref
        .read(fixtureProvider(widget.tournamentId).notifier)
        .generateFixture(
          mode: AppConstants.tournamentModeGroups,
          playerIds: playerIds,
          playerNames: playerNames,
          manualGroups: manualGroups,
        );

    setState(() => _isGenerating = false);
    if (!mounted) return;
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
        title: const Text('Asignar grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Rellenar restantes al azar',
            onPressed: _groups[_unassigned]!.isEmpty ? null : _shuffleRemaining,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text('Grupos: ${_groupLabels.length}',
                    style: AppTextStyles.bodyMedium),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _groupLabels.length > 1 ? _removeLastGroup : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _groupLabels.length < 20 ? _addGroup : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                _GroupSection(
                  label: 'Sin asignar',
                  color: AppColors.grey400,
                  players: _groups[_unassigned]!,
                  onAccept: (p) => _movePlayer(p, _unassigned),
                ),
                for (final label in _groupLabels)
                  _GroupSection(
                    label: 'Grupo $label',
                    color: AppColors.primary,
                    players: _groups[label]!,
                    onAccept: (p) => _movePlayer(p, label),
                  ),
              ],
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

class _GroupSection extends StatelessWidget {
  final String label;
  final Color color;
  final List<PlayerEntity> players;
  final void Function(PlayerEntity player) onAccept;

  const _GroupSection({
    required this.label,
    required this.color,
    required this.players,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlayerEntity>(
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withOpacity(0.15)
                : AppColors.surfaceVariant,
            border: Border.all(
              color: isHovering ? color : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label,
                      style: AppTextStyles.titleMedium.copyWith(color: color)),
                  const SizedBox(width: 8),
                  Text('(${players.length})',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400)),
                ],
              ),
              const SizedBox(height: 8),
              if (players.isEmpty)
                Text('Arrastra jugadores aquí',
                    style:
                        AppTextStyles.bodySmall.copyWith(color: AppColors.grey600))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      players.map((p) => _PlayerChip(player: p)).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final PlayerEntity player;
  const _PlayerChip({required this.player});

  @override
  Widget build(BuildContext context) {
    final chip = Chip(
      avatar: CircleAvatar(
        child: Text(player.name.isNotEmpty ? player.name[0].toUpperCase() : '?'),
      ),
      label: Text(player.name),
    );
    return LongPressDraggable<PlayerEntity>(
      data: player,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.85, child: chip),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}
