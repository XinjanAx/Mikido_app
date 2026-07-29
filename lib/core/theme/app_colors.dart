import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Controlado por [ThemeModeNotifier] cada vez que se cambia el tema.
  /// Se lee de forma síncrona desde los getters de abajo — así toda la app
  /// sigue usando `AppColors.xxx` igual que antes, pero ahora responde al
  /// tema claro/oscuro sin tener que tocar cada pantalla.
  static bool _isDark = true;
  static bool get isDark => _isDark;
  static void setDark(bool value) => _isDark = value;

  // ---------- Colores de marca (iguales en ambos temas) ----------
  // Rojo combate — identidad del club, energía, competencia
  static const Color primary = Color(0xFFBF1C2E);
  static const Color primaryDark = Color(0xFF8C0F1E);
  static const Color primaryLight = Color(0xFFE84057);

  // Dorado medalla — acento para logros, clasificaciones, top 3
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentLight = Color(0xFFE8C96A);

  // Blanco literal: para texto/íconos SOBRE una superficie de color fijo
  // (p. ej. el spinner dentro de un botón rojo). No cambia con el tema.
  static const Color white = Color(0xFFFFFFFF);

  // Semánticos (iguales en ambos temas)
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF1565C0);

  // Estado de torneo
  static const Color statusDraft = Color(0xFF9E9E9E);
  static const Color statusActive = Color(0xFF2E7D32);
  static const Color statusFinished = Color(0xFF1565C0);
  static const Color statusCancelled = Color(0xFFC62828);

  // Posiciones en tabla (top 3)
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // ---------- Fondos (dependen del tema) ----------
  static Color get surface =>
      _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F7F8);
  static Color get surfaceVariant =>
      _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF);
  static Color get border =>
      _isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);

  // ---------- Texto (depende del tema) ----------
  // Reemplazan el uso semántico que antes tenía `white`/`offWhite`/`grey400`
  // como "texto principal/secundario/apagado sobre el fondo de la app".
  static Color get textPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A);
  static Color get textSecondary =>
      _isDark ? const Color(0xFFF5F5F5) : const Color(0xFF3A3A3A);
  static Color get textMuted =>
      _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B6B6B);

  // ---------- Neutros clásicos (ahora dinámicos: mismos nombres de       ----------
  // siempre para no tener que tocar cada pantalla que ya los usaba).
  static Color get offWhite => textSecondary;
  static Color get grey100 =>
      _isDark ? const Color(0xFFE8E8E8) : const Color(0xFF2A2A2A);
  static Color get grey400 => textMuted;
  static Color get grey600 =>
      _isDark ? const Color(0xFF757575) : const Color(0xFF8A8A8A);
  static Color get grey800 =>
      _isDark ? const Color(0xFF424242) : const Color(0xFFD0D0D0);
}
