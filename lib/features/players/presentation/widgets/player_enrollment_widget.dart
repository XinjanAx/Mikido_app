import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../players/domain/entities/player_entity.dart';
import '../providers/player_provider.dart';

/// Widget reutilizable para inscribir/desinscribir un participante
/// en una categoría de un torneo específico.
class PlayerEnrollmentWidget extends ConsumerStatefulWidget {
  final String tournamentId;
  final List<CategoryEntity> categories;
  final List<PlayerEntity> allPlayers;
  final List<PlayerEntity> enrolledPlayers;

  const PlayerEnrollmentWidget({
    super.key,
    required this.tournamentId,
    required this.categories,
    required this.allPlayers,
    required this.enrolledPlayers,
  });

  @override
  ConsumerState<PlayerEnrollmentWidget> createState() =>
      _PlayerEnrollmentWidgetState();
}

class _PlayerEnrollmentWidgetState
    extends ConsumerState<PlayerEnrollmentWidget> {
  String? _selectedCategoryId;
  final Set<String> _enrollingIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrolledIds =
        widget.enrolledPlayers.map((p) => p.id).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de categoría
        if (widget.categories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Inscribir en categoría',
                prefixIcon: Icon(Icons.category_outlined),
                isDense: true,
              ),
              items: widget.categories
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
          ),
          const SizedBox(height: 8),
        ] else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Crea categorías antes de inscribir participantes.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),

        // Lista de jugadores
        ...widget.allPlayers.map((player) {
          final isEnrolled = enrolledIds.contains(player.id);
          final isLoading = _enrollingIds.contains(player.id);

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: isEnrolled
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.1),
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isEnrolled ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            title: Text(player.name, style: AppTextStyles.titleMedium),
            subtitle: player.email != null
                ? Text(player.email!, style: AppTextStyles.bodySmall)
                : null,
            trailing: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : isEnrolled
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text('Inscrito',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: AppColors.success)),
                          ],
                        ),
                      )
                    : _selectedCategoryId != null
                        ? TextButton(
                            onPressed: () =>
                                _enroll(player.id, player.name),
                            child: const Text('Inscribir'),
                          )
                        : const SizedBox.shrink(),
          );
        }),
      ],
    );
  }

  Future<void> _enroll(String playerId, String playerName) async {
    if (_selectedCategoryId == null) return;
    setState(() => _enrollingIds.add(playerId));

    await ref.read(playersProvider.notifier).enrollPlayer(
          playerId: playerId,
          tournamentId: widget.tournamentId,
          categoryId: _selectedCategoryId!,
        );

    setState(() => _enrollingIds.remove(playerId));
  }
}
