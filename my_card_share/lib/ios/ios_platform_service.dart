import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════
/// iOS Platform Service — Central utility for iOS-specific logic.
/// Safe to import on ALL platforms. Android code is never disturbed.
/// ═══════════════════════════════════════════════════════════════
class IOSPlatformService {
  IOSPlatformService._internal();
  static final IOSPlatformService instance = IOSPlatformService._internal();

  /// Returns true ONLY when running on a real iOS device or iOS Simulator.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns true ONLY when running on Android.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// iOS version string (e.g. "17.2"). Empty on non-iOS.
  static String get iOSVersionString {
    if (!isIOS) return '';
    try {
      return Platform.operatingSystemVersion;
    } catch (_) {
      return '';
    }
  }

  /// Returns true if running on iOS 15 or higher.
  static bool get isIOS15OrHigher {
    if (!isIOS) return false;
    try {
      final versionStr = Platform.operatingSystemVersion;
      // Format: "Version 17.2 (Build 21C62)"
      final match = RegExp(r'Version\s+(\d+)').firstMatch(versionStr);
      if (match != null) {
        final major = int.tryParse(match.group(1) ?? '') ?? 0;
        return major >= 15;
      }
    } catch (_) {}
    return false;
  }

  /// Shows a styled iOS-native-feel dialog.
  static Future<void> showIOSDialog({
    required BuildContext context,
    required String title,
    required String message,
    String okLabel = 'OK',
    VoidCallback? onOk,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onOk?.call();
            },
            child: Text(
              okLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF007AFF), // iOS blue
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows an iOS-native-feel Action Sheet (bottom sheet).
  static Future<String?> showActionSheet({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> actions,
    // Each action: {'label': String, 'value': String, 'isDestructive': bool}
    String cancelLabel = 'Cancel',
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Actions group
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ...actions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final action = entry.value;
                      final isDestructive = action['isDestructive'] == true;
                      return Column(
                        children: [
                          if (idx > 0) const Divider(height: 1),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(action['value'] as String),
                            child: Text(
                              action['label'] as String,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: isDestructive
                                    ? const Color(0xFFFF3B30)
                                    : const Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Cancel button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007AFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
