import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_entity.dart';
import '../providers/player_provider.dart';

class PlayerFormScreen extends ConsumerStatefulWidget {
  final PlayerEntity? player;

  const PlayerFormScreen({super.key, this.player});

  @override
  ConsumerState<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends ConsumerState<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;

  bool get _isEdit => widget.player != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player?.name ?? '');
    _emailController = TextEditingController(text: widget.player?.email ?? '');
    _phoneController = TextEditingController(text: widget.player?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    bool success;
    if (_isEdit) {
      final updated = PlayerEntity(
        id: widget.player!.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        birthDate: widget.player!.birthDate,
        photoUrl: widget.player!.photoUrl,
        createdAt: widget.player!.createdAt,
      );
      success = await ref.read(playersProvider.notifier).updatePlayer(updated);
    } else {
      success = await ref.read(playersProvider.notifier).createPlayer(
            name: _nameController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
    }

    setState(() => _isSaving = false);
    if (success && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar participante' : 'Nuevo participante'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo (opcional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty && !v.isValidEmail) {
                    return 'Correo inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: Icon(Icons.phone_outlined),
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
                    : Text(_isEdit ? 'Guardar cambios' : 'Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
