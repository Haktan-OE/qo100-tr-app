import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _labelSize = 12.0;

  static TextTheme textTheme(TextTheme base, ColorScheme colors) {
    return base
        .apply(bodyColor: colors.onSurface, displayColor: colors.onSurface)
        .copyWith(
          headlineMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: const TextStyle(fontSize: 14, height: 1.5),
          labelMedium: const TextStyle(
            fontSize: _labelSize,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        );
  }

  static TextStyle navigationLabel({
    required Color color,
    required bool isSelected,
  }) {
    return TextStyle(
      color: color,
      fontSize: _labelSize,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
    );
  }
}
