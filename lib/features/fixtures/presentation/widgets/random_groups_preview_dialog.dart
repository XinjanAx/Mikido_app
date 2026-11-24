import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../providers/fixture_provider.dart';

/// Muestra cómo quedaron los grupos armados al azar antes de generar el
/// fixture de verdad. Se puede volver a sortear las veces que haga falta;
/// "Continuar" se habilita recién después de una cuenta regresiva de 5s
/// para evitar que se confirme sin mirar los grupos.
class RandomGroupsPreviewDialog extends ConsumerStatefulWidget {
  final String tournamentId;
  final List<PlayerEntity> players;
  final int numberOfGroups;

  const RandomGroupsPreviewDialog({
    super.key,
    required this.tournamentId,
    required this.players,
    required this.numberOfGroups,
  });

  @override
  ConsumerState<RandomGroupsPreviewDialog> createState() =>
      _RandomGroupsPreviewDialogState();
}

class _RandomGroupsPreviewDialogState
    extends ConsumerState<RandomGroupsPreviewDialog> {
  static const _countdownSeconds = 5;

  late List<List<PlayerEntity>> _groups;
  Timer? _timer;
  int _secondsLeft = _countdownSeconds;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _groups = _shuffleGroups();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<List<PlayerEntity>> _shuffleGroups() {
    final shuffled = List<PlayerEntity>.from(widget.players)..shuffle();
    final n = shuffled.length;
    final groups = widget.numberOfGroups.clamp(1, n);
    final baseSize = n ~/ groups;
    final remainder = n % groups;

    final result = <List<PlayerEntity>>[];
    int start = 0;
    for (int g = 0; g < groups; g++) {
      final size = baseSize + (g < remainder ? 1 : 0);
      final end = (start + size).clamp(0, n);
      if (start >= end) break;
      result.add(shuffled.sublist(start, end));
      start = end;
    }
    return result;
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _countdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _reshuffle() {
    setState(() => _groups = _shuffleGroups());
    _startCountdown();
  }

  Future<void> _confirm() async {
    setState(() => _isGenerating = true);

    final manualGroups =
        _groups.map((g) => g.map((p) => p.id).toList()).toList();
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

    if (!mounted) return;
    final errorMessage =
        ref.read(fixtureProvider(widget.tournamentId)).errorMessage;
    Navigator.of(context).pop();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Error al generar los encuentros')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Grupos generados'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _groups.length; i++) ...[
                Text(
                  'Grupo ${String.fromCharCode(65 + i)}',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                ..._groups[i].map((p) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text('• ${p.nameWithAcronym}',
                          style: AppTextStyles.bodyMedium),
                    )),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton.icon(
          onPressed: _isGenerating ? null : _reshuffle,
          icon: const Icon(Icons.shuffle),
          label: const Text('Rearmar'),
        ),
        ElevatedButton(
          onPressed: (_secondsLeft > 0 || _isGenerating) ? null : _confirm,
          child: _isGenerating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.white),
                )
              : Text(_secondsLeft > 0
                  ? 'Continuar (${_secondsLeft}s)'
                  : 'Continuar'),
        ),
      ],
    );
  }
}
