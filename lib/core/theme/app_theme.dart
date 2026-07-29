import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return _themeFor(
      brightness: Brightness.dark,
      scaffoldBackground: const Color(0xFF1A1A1A),
      surfaceVariant: const Color(0xFF2C2C2C),
      onSurface: AppColors.offWhite,
      border: const Color(0xFF3A3A3A),
      hint: const Color(0xFF757575),
    );
  }

  static ThemeData get lightTheme {
    return _themeFor(
      brightness: Brightness.light,
      scaffoldBackground: const Color(0xFFF7F7F8),
      surfaceVariant: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1A1A1A),
      border: const Color(0xFFE0E0E0),
      hint: const Color(0xFF8A8A8A),
    );
  }

  static ThemeData _themeFor({
    required Brightness brightness,
    required Color scaffoldBackground,
    required Color surfaceVariant,
    required Color onSurface,
    required Color border,
    required Color hint,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.accent,
        onSecondary: isDark ? AppColors.surface : AppColors.white,
        surface: surfaceVariant,
        onSurface: onSurface,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineMedium,
      ),
      cardTheme: CardThemeData(
        color: surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTextStyles.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: TextStyle(color: hint),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceVariant,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: hint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        // ignore: deprecated_member_use
        backgroundColor: surfaceVariant,
        // ignore: deprecated_member_use
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: AppTextStyles.labelSmall,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: hint,
        indicatorColor: AppColors.primary,
        labelStyle: AppTextStyles.titleMedium,
      ),
    );
  }
}
