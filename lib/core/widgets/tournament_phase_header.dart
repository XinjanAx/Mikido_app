import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Encabezado de marca reutilizable para pantallas de resultados (llave,
/// tabla de posiciones): logo del club + nombre del torneo + fase. Mismo
/// diseño que usa torneo_web, para que ambos se vean iguales.
class TournamentPhaseHeader extends StatelessWidget {
  final String tournamentName;
  final String phaseLabel;

  const TournamentPhaseHeader({
    super.key,
    required this.tournamentName,
    required this.phaseLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Mismo color que el fondo de la pantalla (no el de las tarjetas):
        // así la banda queda de lado a lado, sin leerse como una barra
        // gris separada del resto — solo la línea roja la delimita.
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/icon/icon.png', height: 36),
              const SizedBox(width: 10),
              Image.asset('assets/images/mikido_wordmark.png', height: 28),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tournamentName,
            style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            phaseLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
