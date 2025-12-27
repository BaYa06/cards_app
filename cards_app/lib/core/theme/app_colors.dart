import 'package:flutter/material.dart';

/// Цветовая палитра приложения DeutschCards
class AppColors {
  AppColors._();

  // Основные цвета (по дизайну)
  static const Color primary = Color(0xFF2D2DE6);
  static const Color primaryDark = Color(0xFF2424B8);
  static const Color primaryLight = Color(0xFF4C4CFF);

  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);

  // Акцентные цвета
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF388E3C);

  // Цвета для карточек
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E1E2F);
  static const Color cardShadow = Color(0x1A000000);

  // Цвета для действий с карточками
  static const Color correctAnswer = Color(0xFF4CAF50);
  static const Color wrongAnswer = Color(0xFFF44336);
  static const Color skipAnswer = Color(0xFFFF9800);

  // Цвета уровней сложности
  static const Color easyLevel = Color(0xFF4CAF50);
  static const Color mediumLevel = Color(0xFFFF9800);
  static const Color hardLevel = Color(0xFFF44336);

  // Текстовые цвета
  static const Color textPrimary = Color(0xFF0E0E1B);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Темная тема (по дизайну)
  static const Color darkBackground = Color(0xFF111121);
  static const Color darkSurface = Color(0xFF1E1E2F);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

  // Светлая тема (по дизайну)
  static const Color lightBackground = Color(0xFFF6F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Дополнительные цвета
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2D2DE6), Color(0xFF4C4CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow shadows
  static BoxShadow get glowShadow => BoxShadow(
    color: primary.withOpacity(0.4),
    blurRadius: 40,
    spreadRadius: 0,
  );

  static BoxShadow get glowShadowSmall => BoxShadow(
    color: primary.withOpacity(0.25),
    blurRadius: 20,
    spreadRadius: 0,
  );

  static BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

  static BoxShadow get cardShadowBox => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 12,
    offset: const Offset(0, 2),
  );
}
