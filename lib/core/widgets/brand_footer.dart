import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Pie de marca reutilizable para pantallas de resultados (llave, tabla
/// de posiciones): línea roja + logo del club en un recuadro.
class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 2, width: 120, color: AppColors.primary),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Image.asset(
            AppColors.isDark
                ? 'assets/images/logo_positivo.png'
                : 'assets/images/logo_negativo.png',
            height: 28,
          ),
        ),
      ],
    );
  }
}
