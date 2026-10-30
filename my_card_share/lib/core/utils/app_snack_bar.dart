import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AppSnackBar — Global fast snackbar utility
/// ─────────────────────────────────────────────────────────────────────────────
/// Always clears the current queue before showing the next message.
/// Snackbars appear INSTANTLY — no waiting for pending ones to dismiss.
///
/// Usage:
///   AppSnackBar.success(context, 'Company approved!');
///   AppSnackBar.error(context, 'Something went wrong.');
///   AppSnackBar.info(context, 'Link copied!');
/// ─────────────────────────────────────────────────────────────────────────────
class AppSnackBar {
  AppSnackBar._();

  static const Duration _short = Duration(seconds: 2);
  static const Duration _medium = Duration(seconds: 3);

  /// ✅ Success — green
  static void success(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF10B981),
      duration: duration ?? _short,
    );
  }

  /// ❌ Error — red
  static void error(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      color: const Color(0xFFDC2626),
      duration: duration ?? _medium,
    );
  }

  /// ⚠️ Warning — amber
  static void warning(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      color: const Color(0xFFD97706),
      duration: duration ?? _medium,
    );
  }

  /// ℹ️ Info — slate blue
  static void info(BuildContext context, String message, {Duration? duration}) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      color: const Color(0xFF0052FF),
      duration: duration ?? _short,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    required Duration duration,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars(); // ⚡ Always clear queue first
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
  }
}
