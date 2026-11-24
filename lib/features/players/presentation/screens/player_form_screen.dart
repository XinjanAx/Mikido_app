import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final TextEditingController _guildController;
  late final TextEditingController _acronymController;
  bool _isSaving = false;

  bool get _isEdit => widget.player != null;

  /// El acrónimo solo aparece (y es obligatorio) cuando hay gremio escrito.
  bool get _hasGuild => _guildController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player?.name ?? '');
    _emailController = TextEditingController(text: widget.player?.email ?? '');
    _phoneController = TextEditingController(text: widget.player?.phone ?? '');
    _guildController = TextEditingController(text: widget.player?.guild ?? '');
    _acronymController =
        TextEditingController(text: widget.player?.guildAcronym ?? '');
    // Redibuja para mostrar u ocultar el campo del acrónimo.
    _guildController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _guildController.dispose();
    _acronymController.dispose();
    super.dispose();
  }

  /// Nombre y gremio se guardan con la primera letra de cada palabra en
  /// mayúscula.
  String get _nameValue => _nameController.text.capitalizeWords();

  String? get _guildValue =>
      _hasGuild ? _guildController.text.capitalizeWords() : null;

  String? get _acronymValue =>
      _hasGuild ? _acronymController.text.trim().toUpperCase() : null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    bool success;
    if (_isEdit) {
      final updated = PlayerEntity(
        id: widget.player!.id,
        name: _nameValue,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        birthDate: widget.player!.birthDate,
        photoUrl: widget.player!.photoUrl,
        createdAt: widget.player!.createdAt,
        guild: _guildValue,
        guildAcronym: _acronymValue,
      );
      success = await ref.read(playersProvider.notifier).updatePlayer(updated);
    } else {
      success = await ref.read(playersProvider.notifier).createPlayer(
            name: _nameValue,
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            guild: _guildValue,
            guildAcronym: _acronymValue,
          );
    }

    setState(() => _isSaving = false);
    if (!mounted) return;
    if (success) {
      context.pop();
    } else {
      final error = ref.read(playersProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Error al guardar el participante')),
      );
    }
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
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa el nombre'
                    : null,
              ),
              const SizedBox(height: 16),
              ..._guildFields(),
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
                keyboardType: TextInputType.number,
                // Solo números (también filtra lo que se pegue).
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  /// Gremio (opcional) y, si se escribió, su acrónimo obligatorio.
  List<Widget> _guildFields() {
    return [
      TextFormField(
        controller: _guildController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Gremio o clan (opcional)',
          prefixIcon: Icon(Icons.shield_outlined),
        ),
      ),
      if (_hasGuild) ...[
        const SizedBox(height: 16),
        TextFormField(
          controller: _acronymController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 4,
          inputFormatters: [
            // Letras (incluye Ñ y tildes) y números, siempre en
            // mayúsculas.
            FilteringTextInputFormatter.allow(
                RegExp(r'[\p{L}0-9]', unicode: true)),
            const _UpperCaseFormatter(),
          ],
          decoration: const InputDecoration(
            labelText: 'Acrónimo del gremio',
            hintText: 'Máx. 4 letras o números',
            prefixIcon: Icon(Icons.short_text),
          ),
          validator: (v) {
            if (!_hasGuild) return null;
            if (v == null || v.trim().isEmpty) {
              return 'Ingresa el acrónimo del gremio';
            }
            return null;
          },
        ),
      ],
    ];
  }
}

/// Convierte a mayúsculas mientras se escribe.
class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
