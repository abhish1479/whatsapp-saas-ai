import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF1D293B);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1D293B);

  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF1D293B);

  // Sky blue primary
  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0284C7);

  static const Color secondary = Color(0xFFF1F5F9);
  static const Color secondaryForeground = Color(0xFF1D293B);

  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF6B7A90);

  static const Color accent = Color(0xFF0EA5E9);
  static const Color accentForeground = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF22C55E);
  static const Color successForeground = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Color(0xFFFFFFFF);

  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE2E8F0);
  static const Color input = Color(0xFFE2E8F0);
  static const Color ring = Color(0xFF0EA5E9);

  static const Color sidebarBackground = Color(0xFFFAFAFA);
  static const Color sidebarForeground = Color(0xFF1D293B);
  static const Color sidebarAccent = Color(0xFFEBF8FE);
  static const Color sidebarAccentForeground = Color(0xFF1D293B);

  static const Gradient gradientPrimary = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient gradientHero = LinearGradient(
    colors: [primary, Color(0xFF3B82F6)], // 217, 91%, 60%
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient gradientCard = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)], // 0, 0%, 100% and 210, 40%, 98%
    begin: Alignment(-1.0, -1.0), // 145deg
    end: Alignment(1.0, 1.0),
  );
}