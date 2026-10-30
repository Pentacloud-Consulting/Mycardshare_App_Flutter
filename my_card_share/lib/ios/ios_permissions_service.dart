import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// ═══════════════════════════════════════════════════════════════
/// iOS Permissions Service
///
/// Handles all iOS runtime permission requests with proper
/// iOS-native-feel dialogs and graceful fallbacks.
///
/// Permissions needed in Info.plist (already added):
///   - NSCameraUsageDescription
///   - NSPhotoLibraryUsageDescription
///   - NSPhotoLibraryAddUsageDescription
///   - NSContactsUsageDescription
///   - NFCReaderUsageDescription
///   - NSMicrophoneUsageDescription
/// ═══════════════════════════════════════════════════════════════
class IOSPermissionsService {
  IOSPermissionsService._internal();
  static final IOSPermissionsService instance = IOSPermissionsService._internal();

  static bool get _isIOS => !kIsWeb && Platform.isIOS;

  // ─── Camera ────────────────────────────────────────────────────────────────

  /// Requests camera permission. Shows rationale dialog on iOS before requesting.
  Future<bool> requestCamera(BuildContext context) async {
    if (!_isIOS) return true; // Android handles its own permissions
    return _requestPermission(
      context: context,
      permission: Permission.camera,
      icon: Icons.camera_alt_rounded,
      iconColor: const Color(0xFF007AFF),
      title: 'Camera Access',
      rationale:
          'My Card Share uses your camera to scan business cards and QR codes.',
    );
  }

  // ─── Photos / Gallery ──────────────────────────────────────────────────────

  Future<bool> requestPhotos(BuildContext context) async {
    if (!_isIOS) return true;
    return _requestPermission(
      context: context,
      permission: Permission.photos,
      icon: Icons.photo_library_rounded,
      iconColor: const Color(0xFF7C3AED),
      title: 'Photo Library Access',
      rationale:
          'My Card Share accesses your photo library to set your profile photo and banner image.',
    );
  }

  // ─── Contacts ──────────────────────────────────────────────────────────────

  Future<bool> requestContacts(BuildContext context) async {
    if (!_isIOS) return true;
    return _requestPermission(
      context: context,
      permission: Permission.contacts,
      icon: Icons.contacts_rounded,
      iconColor: const Color(0xFF16A34A),
      title: 'Contacts Access',
      rationale:
          'My Card Share saves digital business cards directly to your address book.',
    );
  }

  // ─── Notifications ─────────────────────────────────────────────────────────

  Future<bool> requestNotifications(BuildContext context) async {
    if (!_isIOS) return true;
    return _requestPermission(
      context: context,
      permission: Permission.notification,
      icon: Icons.notifications_rounded,
      iconColor: const Color(0xFFFF9500),
      title: 'Notifications',
      rationale:
          'Get notified when someone views your card, exchanges contact info, or sends you leads.',
    );
  }

  // ─── NFC ───────────────────────────────────────────────────────────────────

  Future<bool> requestNFC(BuildContext context) async {
    if (!_isIOS) return true;
    // On iOS, NFC permission is handled at session start automatically — no runtime request needed.
    // The NFCReaderUsageDescription in Info.plist is sufficient.
    debugPrint('[IOSPermissionsService] NFC permission is handled by iOS automatically at session start.');
    return true;
  }

  // ─── Core implementation ───────────────────────────────────────────────────

  Future<bool> _requestPermission({
    required BuildContext context,
    required Permission permission,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String rationale,
  }) async {
    try {
      // Check current status
      final status = await permission.status;

      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        // iOS: User denied "Don't Allow" — must go to Settings
        if (context.mounted) {
          await _showGoToSettingsDialog(context, title: title, icon: icon, iconColor: iconColor);
        }
        return false;
      }

      // Show rationale THEN request (iOS pattern)
      if (context.mounted && !status.isGranted) {
        final shouldRequest = await _showRationaleDialog(
          context,
          title: title,
          rationale: rationale,
          icon: icon,
          iconColor: iconColor,
        );
        if (!shouldRequest) return false;
      }

      // Request the actual permission
      final result = await permission.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('[IOSPermissionsService] Permission request error: $e');
      return false;
    }
  }

  Future<bool> _showRationaleDialog(
    BuildContext context, {
    required String title,
    required String rationale,
    required IconData icon,
    required Color iconColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              '"My Card Share" Would Like to Access $title',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              rationale,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              "Don't Allow",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Allow',
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _showGoToSettingsDialog(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          '$title Permission Required',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'This permission was previously denied. Please enable it in Settings → My Card Share.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF007AFF)),
            ),
          ),
        ],
      ),
    );
  }

  /// Request all permissions needed at app startup on iOS.
  Future<void> requestAllOnAppStart(BuildContext context) async {
    if (!_isIOS) return;
    await requestNotifications(context);
    // Camera and Contacts are requested on-demand when feature is used
  }
}
