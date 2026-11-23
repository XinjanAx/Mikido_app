import 'package:flutter_test/flutter_test.dart';
import 'package:torneo_app/core/theme/category_colors.dart';

void main() {
  const p = CategoryColors.palette;

  test('mesa vacía: sugiere el primer color (rojo)', () {
    expect(CategoryColors.suggest(const []), p[0].hex);
  });

  test('sugiere el primer color que nadie usa en la mesa', () {
    expect(CategoryColors.suggest([p[0].hex, p[1].hex]), p[2].hex);
    expect(CategoryColors.suggest([p[1].hex, null]), p[0].hex);
  });

  test('ignora mayúsculas/minúsculas del hex guardado', () {
    expect(CategoryColors.suggest([p[0].hex.toLowerCase()]), p[1].hex);
  });

  test('paleta completa: repite el menos usado', () {
    final used = [for (final c in p) c.hex, p[0].hex]; // rojo dos veces
    expect(CategoryColors.suggest(used), p[1].hex);
  });

  test('parse', () {
    expect(CategoryColors.parse('#E53935')!.toARGB32(), 0xFFE53935);
    expect(CategoryColors.parse(null), isNull);
    expect(CategoryColors.parse('xyz'), isNull);
  });
}
