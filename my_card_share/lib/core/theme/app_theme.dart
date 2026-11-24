import 'package:flutter/material.dart';
import '../../features/auth/font style/font_style.dart';

/// ============================================================
/// APP COLORS — White • Matte Orange • Warm Cream Theme
/// ============================================================
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color background = Color(0xFFFFFFFF); // White (Base)
  static const Color warmCream = Color(0xFFFAF6F2); // Warm Cream (Hero Background)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFFAF6F2);

  // Brand Matte Orange gradient
  static const Color primary = Color(0xFFD4642C); // Matte Orange (Primary)
  static const Color primaryLight = Color(0xFFE8824E); // Warm Terracotta
  static const List<Color> primaryGradient = [primary, primaryLight];

  // Accents (matches web status-badge colors)
  static const Color accentPurple = Color(0xFF818CF8);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFFBBF24);
  static const Color accentRose = Color(0xFFFB7185);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // dark navy / charcoal
  static const Color textSecondary = Color(0xFF64748B); // slate gray
  static const Color textMuted = Color(0xFF94A3B8);

  // Backwards compatibility aliases
  static const Color textDark = Color(0xFF0F172A);
  static const Color secondary = Color(0xFFE8824E);
  static const Color accent = Color(0xFFD4642C);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);

  // Neumorphism base — Warm Cream
  static const Color neuBase = Color(0xFFFAF6F2);
  static const Color neuShadowDark = Color(0xFFE2D9CF);
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
      // Global SnackBar theme: floating style with proper bottom margin
      // so snackbars appear above the bottom navigation bar (height ~64px)
      // showDuration is intentionally short — always call clearSnackBars() first
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: EdgeInsets.fromLTRB(16, 8, 16, 72),
        showCloseIcon: false,
      ),
    );
  }

  static ThemeData get lightTheme => light;
}


