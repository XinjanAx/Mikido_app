import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/mesa_entity.dart';
import '../providers/mesa_provider.dart';

/// Crear o editar una mesa (solo nombre y descripción).
class MesaFormScreen extends ConsumerStatefulWidget {
  final MesaEntity? mesa; // null = crear

  const MesaFormScreen({super.key, this.mesa});

  @override
  ConsumerState<MesaFormScreen> createState() => _MesaFormScreenState();
}

class _MesaFormScreenState extends ConsumerState<MesaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _isSaving = false;

  bool get _isEdit => widget.mesa != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mesa?.name ?? '');
    _descController =
        TextEditingController(text: widget.mesa?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name = _capitalize(_nameController.text.trim());
    final desc = _descController.text.trim();
    final description = desc.isEmpty ? null : _capitalize(desc);
    final actions = ref.read(mesaActionsProvider);

    try {
      if (_isEdit) {
        await actions.update(widget.mesa!,
            name: name, description: description);
      } else {
        await actions.create(name: name, description: description);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al guardar la mesa: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Editar mesa' : 'Nueva mesa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la mesa',
                  hintText: 'Ej.: Tatami 1, Cancha A, Ring central',
                  prefixIcon: Icon(Icons.table_restaurant_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa un nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
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
                    : Text(_isEdit ? 'Guardar cambios' : 'Crear mesa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
