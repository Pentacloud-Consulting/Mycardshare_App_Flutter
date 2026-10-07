import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enterprise Social Redirect & Deep-linking Service
/// Handles real app-level deep linking and browser redirects for Enterprise social channels.
class EnterpriseSocialRedirectService {
  EnterpriseSocialRedirectService._();
  static final EnterpriseSocialRedirectService instance = EnterpriseSocialRedirectService._();

  /// Formats raw handles/input into a full valid URL for any platform
  static String formatFullUrl(String platform, String rawInput) {
    final cleanInput = rawInput.trim();
    if (cleanInput.isEmpty) return '';

    if (cleanInput.startsWith('http://') || cleanInput.startsWith('https://')) {
      return cleanInput;
    }

    final p = platform.toLowerCase().trim();
    final handle = cleanInput.replaceAll('@', '').replaceAll(' ', '');

    if (p.contains('linkedin')) {
      return 'https://linkedin.com/company/$handle';
    } else if (p.contains('instagram')) {
      return 'https://instagram.com/$handle';
    } else if (p.contains('twitter') || p.contains('x')) {
      return 'https://x.com/$handle';
    } else if (p.contains('facebook')) {
      return 'https://facebook.com/$handle';
    } else if (p.contains('youtube')) {
      return handle.startsWith('@') ? 'https://youtube.com/$handle' : 'https://youtube.com/@$handle';
    } else if (p.contains('github')) {
      return 'https://github.com/$handle';
    } else if (p.contains('whatsapp')) {
      final phone = cleanInput.replaceAll(RegExp(r'[^\d+]'), '').replaceAll('+', '');
      return 'https://wa.me/$phone';
    } else if (p.contains('telegram')) {
      return 'https://t.me/$handle';
    } else if (p.contains('pinterest')) {
      return 'https://pinterest.com/$handle';
    } else if (p.contains('tiktok')) {
      return 'https://tiktok.com/@$handle';
    } else if (p.contains('threads')) {
      return 'https://threads.net/@$handle';
    } else if (p.contains('snapchat')) {
      return 'https://snapchat.com/add/$handle';
    } else if (p.contains('discord')) {
      return cleanInput;
    } else if (p.contains('medium')) {
      return 'https://medium.com/@$handle';
    }

    return 'https://$cleanInput';
  }

  /// Launch platform link with native app scheme fallback to external browser
  static Future<bool> launchSocialPlatform({
    required String platform,
    required String rawInput,
    BuildContext? context,
  }) async {
    final fullUrl = formatFullUrl(platform, rawInput);
    if (fullUrl.isEmpty) {
      if (context != null && context.mounted) {
        _showToast(context, "No link provided for $platform");
      }
      return false;
    }

    final uri = Uri.tryParse(fullUrl);
    if (uri == null) {
      if (context != null && context.mounted) {
        _showToast(context, "Invalid link for $platform");
      }
      return false;
    }

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('[EnterpriseSocialRedirect] Error launching $platform ($fullUrl): $e');
      if (context != null && context.mounted) {
        _showToast(context, "Could not open $platform link");
      }
      return false;
    }
  }

  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF0F172A),
      ),
    );
  }
}


