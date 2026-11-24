import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/player_entity.dart';

class PlayerCard extends StatelessWidget {
  final PlayerEntity player;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.15),
          backgroundImage:
              player.photoUrl != null ? NetworkImage(player.photoUrl!) : null,
          child: player.photoUrl == null
              ? Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        // "Nombre - Gremio completo" (el gremio en gris, si lo tiene).
        title: Text.rich(
          TextSpan(
            text: player.name,
            children: [
              if (player.guild != null && player.guild!.isNotEmpty)
                TextSpan(
                  text: ' - ${player.guild}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.grey400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          style: AppTextStyles.titleMedium,
        ),
        subtitle: player.email != null
            ? Text(player.email!, style: AppTextStyles.bodySmall)
            : null,
        trailing: isAdmin && onDelete != null
            ? IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.grey400, size: 20),
                onPressed: onDelete,
              )
            : Icon(Icons.chevron_right, color: AppColors.grey600),
      ),
    );
  }
}
