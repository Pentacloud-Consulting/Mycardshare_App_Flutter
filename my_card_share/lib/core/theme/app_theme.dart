import 'package:flutter/material.dart';
import '../../features/auth/font style/font_style.dart';

/// ============================================================
/// APP COLORS — Light White & Blue Theme
/// ============================================================
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color background = Color(0xFFF5F8FF); // soft blue-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFEFF4FF);

  // Brand blue gradient
  static const Color primary = Color(0xFF0052FF);
  static const Color primaryLight = Color(0xFF38BDF8);
  static const List<Color> primaryGradient = [primary, primaryLight];

  // Accents (matches web status-badge colors)
  static const Color accentPurple = Color(0xFF818CF8);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentRose = Color(0xFFFB7185);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // dark navy
  static const Color textSecondary = Color(0xFF64748B); // gray
  static const Color textMuted = Color(0xFF94A3B8);

  // Backwards compatibility aliases
  static const Color textDark = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color accent = Color(0xFF818CF8);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // Neumorphism base — MUST stay close to background for the dual-shadow
  // effect to read correctly. Don't use pure white here.
  static const Color neuBase = Color(0xFFF0F4FF);
  static const Color neuShadowDark = Color(0xFFC4CFE6);
  static const Color neuShadowLight = Color(0xFFFFFFFF);

  // Glass overlay tints
  static Color glassWhite = Colors.white.withValues(alpha: 0.55);
  static Color glassBorder = Colors.white.withValues(alpha: 0.35);
}

/// ============================================================
/// APP TEXT STYLES — Powered by AppFontStyle
/// ============================================================
class AppTextStyles {
  AppTextStyles._();

  // Backwards compatibility getters
  static TextStyle get headline => AppFontStyle.headlineLarge;
  static TextStyle get title => AppFontStyle.titleLarge;
  static TextStyle get body => AppFontStyle.bodyLarge;
  static TextStyle get caption => AppFontStyle.caption;

  static TextTheme get textTheme => AppFontStyle.textTheme;
}

/// ============================================================
/// APP THEME — ThemeData assembly. Wire this into MaterialApp:
///   MaterialApp(theme: AppTheme.light, ...)
/// ============================================================
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: AppTextStyles.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.textTheme.titleLarge,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }

  static ThemeData get lightTheme => light;
}
