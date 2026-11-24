import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.dark) {
    AppColors.setDark(true);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'light') {
      AppColors.setDark(false);
      state = ThemeMode.light;
      _rebuildAll();
    }
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    AppColors.setDark(next == ThemeMode.dark);
    state = next;
    _rebuildAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }

  /// [AppColors] y [AppTextStyles] son getters globales: los widgets que
  /// los leen no dependen del `Theme`, así que Flutter no los reconstruye
  /// al cambiar el tema y se quedaban con los colores viejos (p. ej. texto
  /// blanco sobre fondo claro) hasta salir y volver a la pantalla. Se marca
  /// todo el árbol para reconstruir — incluidas las pantallas de atrás en
  /// la pila de navegación — sin perder estado ni navegación.
  static void _rebuildAll() {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return;
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }

    mark(root);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
