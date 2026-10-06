import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Social Redirect Service
/// Handles real app-level deep linking and web redirects for social platforms,
/// contact phone numbers, emails, and custom URLs.
class SocialRedirectService {
  SocialRedirectService._();

  static final SocialRedirectService instance = SocialRedirectService._();

  /// Redirect to a specific social platform given platform name and raw handle/URL
  static Future<bool> launchSocialPlatform({
    required String platform,
    required String rawInput,
    BuildContext? context,
  }) async {
    final cleanInput = rawInput.trim();
    if (cleanInput.isEmpty) {
      if (context != null && context.mounted) {
        _showSnackBar(context, "No link available for $platform");
      }
      return false;
    }

    final p = platform.toLowerCase().trim();

    if (p.contains('linkedin')) {
      return await launchLinkedIn(cleanInput, context: context);
    } else if (p.contains('instagram')) {
      return await launchInstagram(cleanInput, context: context);
    } else if (p.contains('whatsapp')) {
      return await launchWhatsApp(cleanInput, context: context);
    } else if (p.contains('youtube')) {
      return await launchYouTube(cleanInput, context: context);
    } else if (p.contains('twitter') || p.contains('x')) {
      return await launchTwitterX(cleanInput, context: context);
    } else if (p.contains('github')) {
      return await launchGitHub(cleanInput, context: context);
    } else if (p.contains('pinterest')) {
      return await launchPinterest(cleanInput, context: context);
    } else if (p.contains('telegram')) {
      return await launchTelegram(cleanInput, context: context);
    } else if (p.contains('facebook')) {
      return await launchFacebook(cleanInput, context: context);
    } else if (p.contains('email') || p.contains('mail')) {
      return await launchEmail(cleanInput, context: context);
    } else if (p.contains('phone') || p.contains('call') || p.contains('tel')) {
      return await launchPhone(cleanInput, context: context);
    } else {
      // Generic Web link or Portfolio
      return await launchGenericUrl(cleanInput, context: context);
    }
  }

  // --------------------------------------------------------------------------
  // LINKEDIN
  // --------------------------------------------------------------------------
  static Future<bool> launchLinkedIn(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 'linkedin.com');
    if (handle.isEmpty) return false;

    // Native app deep link scheme
    final appUri = Uri.parse("linkedin://in/$handle");
    // Web fallback URL
    final webUri = Uri.parse("https://www.linkedin.com/in/$handle");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "LinkedIn",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // INSTAGRAM
  // --------------------------------------------------------------------------
  static Future<bool> launchInstagram(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 'instagram.com');
    if (handle.isEmpty) return false;

    // Native app deep link scheme
    final appUri = Uri.parse("instagram://user?username=$handle");
    // Web fallback URL
    final webUri = Uri.parse("https://www.instagram.com/$handle/");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "Instagram",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // WHATSAPP
  // --------------------------------------------------------------------------
  static Future<bool> launchWhatsApp(String input, {BuildContext? context}) async {
    // Strip non-digits except +
    final cleanPhone = input.replaceAll(RegExp(r'[^\d+]'), '').replaceAll('+', '');
    if (cleanPhone.isEmpty) {
      if (context != null && context.mounted) {
        _showSnackBar(context, "Invalid WhatsApp phone number");
      }
      return false;
    }

    final appUri = Uri.parse("whatsapp://send?phone=$cleanPhone");
    final webUri = Uri.parse("https://wa.me/$cleanPhone");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "WhatsApp",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // YOUTUBE
  // --------------------------------------------------------------------------
  static Future<bool> launchYouTube(String input, {BuildContext? context}) async {
    String handle = _extractHandle(input, domain: 'youtube.com');
    if (!handle.startsWith('@') && !handle.contains('/')) {
      handle = '@$handle';
    }

    final appUri = Uri.parse("vnd.youtube://www.youtube.com/$handle");
    final webUri = Uri.parse("https://www.youtube.com/$handle");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "YouTube",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // TWITTER / X
  // --------------------------------------------------------------------------
  static Future<bool> launchTwitterX(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 'twitter.com').replaceAll(RegExp(r'x\.com'), '');
    if (handle.isEmpty) return false;

    final appUri = Uri.parse("twitter://user?screen_name=$handle");
    final webUri = Uri.parse("https://x.com/$handle");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "X (Twitter)",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // GITHUB
  // --------------------------------------------------------------------------
  static Future<bool> launchGitHub(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 'github.com');
    if (handle.isEmpty) return false;

    final webUri = Uri.parse("https://github.com/$handle");
    return await _launchSingleUri(webUri, platformName: "GitHub", context: context);
  }

  // --------------------------------------------------------------------------
  // PINTEREST
  // --------------------------------------------------------------------------
  static Future<bool> launchPinterest(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 'pinterest.com');
    if (handle.isEmpty) return false;

    final appUri = Uri.parse("pinterest://user/$handle/");
    final webUri = Uri.parse("https://www.pinterest.com/$handle/");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "Pinterest",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // TELEGRAM
  // --------------------------------------------------------------------------
  static Future<bool> launchTelegram(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 't.me');
    if (handle.isEmpty) return false;

    final appUri = Uri.parse("tg://resolve?domain=$handle");
    final webUri = Uri.parse("https://t.me/$handle");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "Telegram",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // FACEBOOK
  // --------------------------------------------------------------------------
  static Future<bool> launchFacebook(String input, {BuildContext? context}) async {
    final handle = _extractHandle(input, domain: 'facebook.com');
    if (handle.isEmpty) return false;

    final appUri = Uri.parse("fb://facewebmodal/f?href=https://www.facebook.com/$handle");
    final webUri = Uri.parse("https://www.facebook.com/$handle");

    return await _launchWithFallback(
      appUri: appUri,
      webUri: webUri,
      platformName: "Facebook",
      context: context,
    );
  }

  // --------------------------------------------------------------------------
  // EMAIL
  // --------------------------------------------------------------------------
  static Future<bool> launchEmail(String email, {BuildContext? context}) async {
    final cleanEmail = email.replaceAll('mailto:', '').trim();
    if (cleanEmail.isEmpty) return false;

    final uri = Uri.parse("mailto:$cleanEmail");
    return await _launchSingleUri(uri, platformName: "Email", context: context);
  }

  // --------------------------------------------------------------------------
  // PHONE / CALL
  // --------------------------------------------------------------------------
  static Future<bool> launchPhone(String phone, {BuildContext? context}) async {
    final cleanPhone = phone.replaceAll('tel:', '').trim();
    if (cleanPhone.isEmpty) return false;

    final uri = Uri.parse("tel:$cleanPhone");
    return await _launchSingleUri(uri, platformName: "Phone Call", context: context);
  }

  // --------------------------------------------------------------------------
  // GENERIC WEBSITE / PORTFOLIO URL
  // --------------------------------------------------------------------------
  static Future<bool> launchGenericUrl(String rawUrl, {BuildContext? context}) async {
    var formattedUrl = rawUrl.trim();
    if (formattedUrl.isEmpty) return false;

    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    final uri = Uri.tryParse(formattedUrl);
    if (uri == null) {
      if (context != null && context.mounted) {
        _showSnackBar(context, "Invalid web address: $rawUrl");
      }
      return false;
    }

    return await _launchSingleUri(uri, platformName: "Website", context: context);
  }

  // --------------------------------------------------------------------------
  // PRIVATE HELPER LAUNCHERS
  // --------------------------------------------------------------------------
  static Future<bool> _launchWithFallback({
    required Uri appUri,
    required Uri webUri,
    required String platformName,
    BuildContext? context,
  }) async {
    try {
      // 1. Try launching native app deep link
      if (await canLaunchUrl(appUri)) {
        final launched = await launchUrl(appUri, mode: LaunchMode.externalNonBrowserApplication);
        if (launched) return true;
      }
    } catch (e) {
      debugPrint("[SocialRedirect] Native app launch error ($platformName): $e");
    }

    // 2. Fall back to external web browser
    try {
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback try platform default
        return await launchUrl(webUri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("[SocialRedirect] Web fallback launch error ($platformName): $e");
      if (context != null && context.mounted) {
        _showSnackBar(context, "Unable to open $platformName");
      }
      return false;
    }
  }

  static Future<bool> _launchSingleUri(
    Uri uri, {
    required String platformName,
    BuildContext? context,
  }) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("[SocialRedirect] Launch error ($platformName): $e");
      if (context != null && context.mounted) {
        _showSnackBar(context, "Unable to open $platformName link");
      }
      return false;
    }
  }

  static String _extractHandle(String input, {required String domain}) {
    var s = input.trim();
    if (s.isEmpty) return '';

    // Remove leading '@'
    if (s.startsWith('@')) s = s.substring(1);

    // If input is full URL like https://instagram.com/username
    if (s.contains('http://') || s.contains('https://') || s.contains(domain)) {
      try {
        final uri = Uri.parse(s.startsWith('http') ? s : 'https://$s');
        final segments = uri.pathSegments.where((seg) => seg.trim().isNotEmpty).toList();
        if (segments.isNotEmpty) {
          // Exclude common url parts like 'in', 'user', 'channel', etc. if needed
          var handle = segments.last;
          if (handle == 'in' && segments.length > 1) {
            handle = segments.firstWhere((seg) => seg != 'in', orElse: () => segments.last);
          }
          return handle.replaceAll('@', '');
        }
      } catch (_) {}
    }

    return s.replaceAll('/', '').trim();
  }

  static void _showSnackBar(BuildContext context, String message) {
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
