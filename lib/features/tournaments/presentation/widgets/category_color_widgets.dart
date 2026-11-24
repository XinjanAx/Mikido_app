import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/category_colors.dart';
import '../providers/tournament_provider.dart';

/// Fondo de la barra superior de las pantallas de una categoría: el color
/// de la categoría a la izquierda, que se desvanece a transparente hacia la
/// derecha (fundiéndose con el fondo de la app). Se usa como
/// `AppBar(flexibleSpace: CategoryHeaderGradient(tournamentId: ...))`.
///
/// La opacidad máxima es moderada a propósito: así el título y los íconos
/// del tema se leen bien sobre cualquier color de la paleta, tanto en modo
/// claro como oscuro.
class CategoryHeaderGradient extends ConsumerWidget {
  final String tournamentId;

  const CategoryHeaderGradient({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hex = ref.watch(tournamentByIdProvider(tournamentId))?.color;
    final color = CategoryColors.parse(hex);
    if (color == null) return const SizedBox.shrink();

    // SizedBox.expand: un DecoratedBox sin hijo recibe del AppBar
    // restricciones sueltas y se queda en 0×0 — el degradado nunca se veía.
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0.65),
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.45, 0.9],
          ),
        ),
      ),
    );
  }
}

/// Franja vertical con el color de la categoría, para tarjetas y listas
/// (lista de categorías de la mesa y cola de la mesa).
class CategoryColorStrip extends StatelessWidget {
  final String? hex;
  final double width;

  const CategoryColorStrip({super.key, required this.hex, this.width = 5});

  @override
  Widget build(BuildContext context) {
    final color = CategoryColors.parse(hex);
    if (color == null) return const SizedBox.shrink();
    return Container(width: width, color: color);
  }
}
