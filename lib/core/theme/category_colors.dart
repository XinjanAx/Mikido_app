import 'package:flutter/material.dart';

/// Color que identifica a una categoría (barra superior con degradado, la
/// tarjeta de la lista y la cola de la mesa). Se guarda como '#RRGGBB' en
/// `tournaments.color`.
class CategoryColor {
  final String name;
  final String hex;

  const CategoryColor(this.name, this.hex);

  Color get color => CategoryColors.parse(hex)!;
}

class CategoryColors {
  CategoryColors._();

  /// Paleta de colores puros y bien distintos entre sí, para que las
  /// categorías de una misma mesa se reconozcan de un vistazo. El orden es
  /// el de sugerencia: primero los primarios.
  static const palette = [
    CategoryColor('Rojo', '#E53935'),
    CategoryColor('Azul', '#1E88E5'),
    CategoryColor('Amarillo', '#FDD835'),
    CategoryColor('Verde', '#43A047'),
    CategoryColor('Naranja', '#FB8C00'),
    CategoryColor('Morado', '#8E24AA'),
    CategoryColor('Celeste', '#00ACC1'),
    CategoryColor('Rosa', '#D81B60'),
  ];

  static Color? parse(String? hex) {
    if (hex == null) return null;
    final clean = hex.replaceFirst('#', '');
    if (clean.length != 6) return null;
    final value = int.tryParse(clean, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  /// Primer color de la paleta que no usa ninguna otra categoría de la
  /// mesa. Si ya se usaron todos, el menos repetido (se permite repetir).
  static String suggest(Iterable<String?> usedInMesa) {
    final counts = <String, int>{for (final c in palette) c.hex: 0};
    for (final hex in usedInMesa) {
      if (hex != null && counts.containsKey(hex.toUpperCase())) {
        counts[hex.toUpperCase()] = counts[hex.toUpperCase()]! + 1;
      }
    }
    var best = palette.first.hex;
    for (final c in palette) {
      if (counts[c.hex]! < counts[best]!) best = c.hex;
    }
    return best;
  }
}
