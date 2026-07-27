import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Widget de formulario reutilizable para ingresar el marcador de un partido.
class ResultFormWidget extends StatefulWidget {
  final String homePlayerName;
  final String awayPlayerName;
  final int? initialHomeScore;
  final int? initialAwayScore;
  final bool isSaving;
  final void Function(int homeScore, int awayScore, String? notes) onSave;
  final VoidCallback? onCancel;

  const ResultFormWidget({
    super.key,
    required this.homePlayerName,
    required this.awayPlayerName,
    required this.isSaving,
    required this.onSave,
    this.initialHomeScore,
    this.initialAwayScore,
    this.onCancel,
  });

  @override
  State<ResultFormWidget> createState() => _ResultFormWidgetState();
}

class _ResultFormWidgetState extends State<ResultFormWidget> {
  late final TextEditingController _homeController;
  late final TextEditingController _awayController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _homeController = TextEditingController(
        text: widget.initialHomeScore?.toString() ?? '0');
    _awayController = TextEditingController(
        text: widget.initialAwayScore?.toString() ?? '0');
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _increment(TextEditingController c) {
    final v = int.tryParse(c.text) ?? 0;
    c.text = '${v + 1}';
  }

  void _decrement(TextEditingController c) {
    final v = int.tryParse(c.text) ?? 0;
    if (v > 0) c.text = '${v - 1}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final home = int.tryParse(_homeController.text) ?? 0;
    final away = int.tryParse(_awayController.text) ?? 0;
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    widget.onSave(home, away, notes);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marcador
          Row(
            children: [
              // Local
              Expanded(
                child: _ScoreInput(
                  playerName: widget.homePlayerName,
                  controller: _homeController,
                  onIncrement: () => _increment(_homeController),
                  onDecrement: () => _decrement(_homeController),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'vs',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.grey400),
                ),
              ),
              // Visitante
              Expanded(
                child: _ScoreInput(
                  playerName: widget.awayPlayerName,
                  controller: _awayController,
                  onIncrement: () => _increment(_awayController),
                  onDecrement: () => _decrement(_awayController),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Notas opcionales
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Observaciones (opcional)',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 28),

          // Botones
          Row(
            children: [
              if (widget.onCancel != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.isSaving ? null : widget.onCancel,
                    child: const Text('Cancelar'),
                  ),
                ),
              if (widget.onCancel != null) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.isSaving ? null : _submit,
                  child: widget.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white),
                        )
                      : const Text('Guardar resultado'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreInput extends StatelessWidget {
  final String playerName;
  final TextEditingController controller;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ScoreInput({
    required this.playerName,
    required this.controller,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          playerName,
          style: AppTextStyles.titleMedium,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botón -
            _ScoreButton(icon: Icons.remove, onTap: onDecrement),
            const SizedBox(width: 8),
            // Campo numérico
            SizedBox(
              width: 64,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: AppTextStyles.scoreDisplay,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return '';
                  if (int.tryParse(v) == null) return '';
                  if (int.parse(v) < 0) return '';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            // Botón +
            _ScoreButton(icon: Icons.add, onTap: onIncrement),
          ],
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScoreButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Icon(icon, size: 18, color: AppColors.offWhite),
      ),
    );
  }
}
