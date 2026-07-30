import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class TournamentStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const TournamentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  Color get _color {
    switch (status) {
      case AppConstants.statusActive:
        return AppColors.statusActive;
      case AppConstants.statusFinished:
        return AppColors.statusFinished;
      case AppConstants.statusCancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.statusDraft;
    }
  }

  String get _label {
    switch (status) {
      case AppConstants.statusDraft:
        return 'Borrador';
      case AppConstants.statusActive:
        return 'En curso';
      case AppConstants.statusFinished:
        return 'Finalizado';
      case AppConstants.statusCancelled:
        return 'Cancelado';
      default:
        return status;
    }
  }

  IconData get _icon {
    switch (status) {
      case AppConstants.statusActive:
        return Icons.play_circle_outline;
      case AppConstants.statusFinished:
        return Icons.check_circle_outline;
      case AppConstants.statusCancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.edit_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 10 : 12, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: AppTextStyles.labelSmall.copyWith(color: _color),
          ),
        ],
      ),
    );
  }
}
