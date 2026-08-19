import 'package:flutter/material.dart';
import 'package:qo100_tr/app/theme/app_colors.dart';
import 'package:qo100_tr/app/theme/app_radius.dart';
import 'package:qo100_tr/app/theme/app_typography.dart';

abstract final class AppComponentThemes {
  static AppBarTheme appBarTheme(ColorScheme colors) => AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: colors.onSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
  );

  static CardThemeData cardTheme(ColorScheme colors) => CardThemeData(
    color: colors.surfaceContainer,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: BorderSide(color: AppColors.outline),
    ),
  );

  static NavigationBarThemeData navigationBarTheme(ColorScheme colors) {
    return NavigationBarThemeData(
      height: 72,
      backgroundColor: colors.surface,
      elevation: 0,
      indicatorColor: colors.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected ? colors.primary : AppColors.textSecondary,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return AppTypography.navigationLabel(
          color: isSelected ? colors.primary : AppColors.textSecondary,
          isSelected: isSelected,
        );
      }),
    );
  }
}
