import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Paleta principal MIKIDO
  // Rojo combate — identidad del club, energía, competencia
  static const Color primary = Color(0xFFBF1C2E);
  static const Color primaryDark = Color(0xFF8C0F1E);
  static const Color primaryLight = Color(0xFFE84057);

  // Negro tatami — fondo oscuro, autoridad, tradición
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF2C2C2C);

  // Dorado medalla — acento para logros, clasificaciones, top 3
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentLight = Color(0xFFE8C96A);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color grey100 = Color(0xFFE8E8E8);
  static const Color grey400 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);

  // Semánticos
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
}
