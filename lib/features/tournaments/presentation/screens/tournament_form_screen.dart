import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/tournament_entity.dart';
import '../providers/tournament_provider.dart';

class TournamentFormScreen extends ConsumerStatefulWidget {
  final TournamentEntity? tournament; // null = crear

  const TournamentFormScreen({super.key, this.tournament});

  @override
  ConsumerState<TournamentFormScreen> createState() =>
      _TournamentFormScreenState();
}

class _TournamentFormScreenState extends ConsumerState<TournamentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late String _selectedMode;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isSaving = false;

  bool get _isEdit => widget.tournament != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.tournament?.name ?? '');
    _descController =
        TextEditingController(text: widget.tournament?.description ?? '');
    _selectedMode =
        widget.tournament?.mode ?? AppConstants.tournamentModeGroups;
    _startDate = widget.tournament?.startDate ?? DateTime.now();
    _endDate = widget.tournament?.endDate ?? DateTime.now();
    _startTime = widget.tournament != null
        ? TimeOfDay.fromDateTime(widget.tournament!.startDate)
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.tournament != null
        ? TimeOfDay.fromDateTime(widget.tournament!.endDate)
        : const TimeOfDay(hour: 18, minute: 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final startDateTime = _combine(_startDate, _startTime);
    final endDateTime = _combine(_endDate, _endTime);
    if (!endDateTime.isAfter(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha y hora de fin debe ser posterior al inicio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);

    final name = _capitalize(_nameController.text.trim());
    final description = _descController.text.trim().isEmpty
        ? null
        : _capitalize(_descController.text.trim());

    bool success;
    if (_isEdit) {
      final updated = TournamentEntity(
        id: widget.tournament!.id,
        name: name,
        mode: _selectedMode,
        status: widget.tournament!.status,
        description: description,
        startDate: startDateTime,
        endDate: endDateTime,
        createdBy: widget.tournament!.createdBy,
        createdAt: widget.tournament!.createdAt,
      );
      success =
          await ref.read(tournamentsProvider.notifier).updateTournament(updated);
    } else {
      success = await ref.read(tournamentsProvider.notifier).createTournament(
            name: name,
            mode: _selectedMode,
            startDate: startDateTime,
            endDate: endDateTime,
            description: description,
          );
    }

    setState(() => _isSaving = false);
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar torneo' : 'Nuevo torneo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del torneo',
                  prefixIcon: Icon(Icons.emoji_events_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Modalidad
              Text('Modalidad', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _buildModeSelector(),
              const SizedBox(height: 24),

              // Fechas
              Text('Fechas', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Inicio',
                      date: _startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Fin',
                      date: _endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'Hora inicio',
                      time: _startTime,
                      onTap: () => _pickTime(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeField(
                      label: 'Hora fin',
                      time: _endTime,
                      onTap: () => _pickTime(isStart: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Se usan para avisarte con anticipación (30, 10 y 5 min '
                'antes de empezar; 1h, 30, 10 y 5 min antes de terminar).',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey400),
              ),
              const SizedBox(height: 36),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(_isEdit ? 'Guardar cambios' : 'Crear torneo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    final modes = [
      (AppConstants.tournamentModeGroups, 'Por grupos', Icons.grid_view_rounded),
      (AppConstants.tournamentModeElimination, 'Eliminación simple',
          Icons.account_tree_outlined),
      (AppConstants.tournamentModeLeague, 'Liga', Icons.leaderboard_outlined),
    ];
    return Column(
      children: modes.map((m) {
        final isSelected = _selectedMode == m.$1;
        return GestureDetector(
          onTap: () => setState(() => _selectedMode = m.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  // ignore: deprecated_member_use
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(m.$3,
                    color: isSelected ? AppColors.primary : AppColors.grey400,
                    size: 22),
                const SizedBox(width: 12),
                Text(m.$2,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.offWhite,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    )),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey400)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.grey400),
                const SizedBox(width: 6),
                Text(date.toDisplayDate(), style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey400)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 14, color: AppColors.grey400),
                const SizedBox(width: 6),
                Text(time.format(context), style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
