import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/category_provider.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  final CategoryEntity? category; // null = crear

  const CategoryFormScreen({
    super.key,
    required this.tournamentId,
    this.category,
  });

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  late final TextEditingController _maxParticipantsController;
  bool _isSaving = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _descController =
        TextEditingController(text: widget.category?.description ?? '');
    _minAgeController = TextEditingController(
        text: widget.category?.minAge?.toString() ?? '');
    _maxAgeController = TextEditingController(
        text: widget.category?.maxAge?.toString() ?? '');
    _maxParticipantsController = TextEditingController(
        text: widget.category?.maxParticipants?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final success = await ref
        .read(categoriesProvider(widget.tournamentId).notifier)
        .createCategory(
          name: _nameController.text.trim(),
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
        );

    setState(() => _isSaving = false);
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar categoría' : 'Nueva categoría'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                  hintText: 'Ej: Sub-12, Senior, Femenino',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              Text('Restricciones (opcional)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edad mín.',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          if (int.tryParse(v) == null) return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Edad máx.',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          if (int.tryParse(v) == null) return 'Número inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Máximo de participantes (opcional)',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    if (int.tryParse(v) == null) return 'Número inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.white),
                      )
                    : Text(_isEdit ? 'Guardar cambios' : 'Crear categoría'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
