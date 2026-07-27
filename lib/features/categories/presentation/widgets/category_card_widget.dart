import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isAdmin;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.category_outlined,
              color: AppColors.accent, size: 20),
        ),
        title: Text(category.name, style: AppTextStyles.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.description != null)
              Text(category.description!, style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                if (category.minAge != null || category.maxAge != null)
                  _Chip(
                    label: _ageLabel,
                    icon: Icons.cake_outlined,
                  ),
                if (category.maxParticipants != null)
                  _Chip(
                    label: 'Máx. ${category.maxParticipants}',
                    icon: Icons.people_outline,
                  ),
              ],
            ),
          ],
        ),
        trailing: isAdmin && onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.grey400, size: 20),
                onPressed: onDelete,
              )
            : onTap != null
                ? const Icon(Icons.chevron_right, color: AppColors.grey600)
                : null,
      ),
    );
  }

  String get _ageLabel {
    if (category.minAge != null && category.maxAge != null) {
      return '${category.minAge}–${category.maxAge} años';
    }
    if (category.minAge != null) return '+${category.minAge} años';
    if (category.maxAge != null) return 'Hasta ${category.maxAge} años';
    return '';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.grey400),
        const SizedBox(width: 3),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
