import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// FONT STYLE MANAGER — Fixed App Typography System
/// Ensures font styles and text sizes stay 100% consistent across
/// all Android/iOS APK builds and do NOT sync/distort with mobile
/// system font settings or custom phone themes.
/// ============================================================
class AppFontStyle {
  AppFontStyle._();

  /// Primary font family bundled inside the APK assets
  static const String fontFamily = 'PlusJakartaSans';
  static const List<String> fontFallback = ['PlusJakartaSans', 'sans-serif'];

  /// Initializes font configuration to force bundled local asset loading
  /// and disable runtime HTTP fetching.
  static void init() {
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  /// Wraps MaterialApp builder to enforce fixed text scaling (TextScaler.noScaling)
  /// so APK builds never inherit system mobile accessibility font overrides.
  static Widget preventSystemFontScaling(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: child,
    );
  }

  // Locked typography styles using bundled font family
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
        height: 1.2,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
        height: 1.25,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.3,
      );

  static TextStyle get titleLarge => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.2,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF64748B),
        height: 1.45,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: Color(0xFF64748B),
        height: 1.45,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: Color(0xFF94A3B8),
      );

  static TextStyle get buttonText => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 14.5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  /// Comprehensive TextTheme connected to MaterialApp
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: caption,
        labelLarge: buttonText,
      );
}
