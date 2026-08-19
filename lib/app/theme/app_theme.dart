import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_component_themes.dart';
import 'package:qo100_tr/app/theme/app_typography.dart';

abstract final class AppTheme {
  static final ColorScheme _darkColorScheme = const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.surfaceElevated,
    onPrimaryContainer: AppColors.primaryStrong,
    secondary: AppColors.primaryStrong,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainer: AppColors.surfaceElevated,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    outline: AppColors.outline,
  );

  static ThemeData get dark {
    final colors = _darkColorScheme;
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: AppTypography.textTheme(base.textTheme, colors),
      appBarTheme: AppComponentThemes.appBarTheme(colors),
      cardTheme: AppComponentThemes.cardTheme(colors),
      navigationBarTheme: AppComponentThemes.navigationBarTheme(colors),
      dividerColor: AppColors.outline,
    );
  }
}
