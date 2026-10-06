import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Definisi tema Material 3 global aplikasi.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        // Micro-interaction: saat konten discroll, app bar naik elevasi
        // secara halus (bawaan Material 3) alih-alih diam datar terus.
        scrolledUnderElevation: 2,
        shadowColor: AppColors.shadow.withOpacity(0.12),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.2),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleSmall: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        labelMedium: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
      ),
      // Elevasi lembut + shadow halus menggantikan gaya flat+border murni,
      // agar hierarki visual antar card lebih terasa tanpa jadi berat.
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 1.5,
        shadowColor: AppColors.shadow.withOpacity(0.10),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primaryLight,
        labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusXl)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
    );
  }
}
