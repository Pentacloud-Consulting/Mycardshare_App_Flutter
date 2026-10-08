import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user_view_card/scanned_profile_view_screen.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// QrRedirectHandler
/// ────────────────────────────────────────────────────────────────────────────
/// Called immediately after the device qr_scanner reads a code.
///
/// Decision logic:
///   • If the scanned URL is a MyCardShare card link
///     (`mycardshare.com/card/<slug>`), we open the rich in-app profile view
///     [ScannedProfileViewScreen] — regardless of whether it's your own card
///     or someone else's.
///   • If the person who SCANNED does NOT have the app (they opened the link
///     in a browser) they naturally land on the web card page; this file is
///     only relevant when the app IS installed.
///   • Any other URL (LinkedIn, website, etc.) is opened in the device browser.
///
/// Usage — call from your qr_scanner result callback:
/// ```dart
/// QrRedirectHandler.handle(context, scannedUrl);
/// ```
class QrRedirectHandler {
  QrRedirectHandler._();

  /// Base domains that belong to the MyCardShare platform.
  static const _cardDomains = [
    'mycardshare.com',
    'mycardshare.vercel.app',
    'localhost',
    '127.0.0.1',
  ];

  static const _cardPathPrefix = '/card/';

  /// Determines the route and navigates accordingly.
  ///
  /// [rawUrl] — the raw string decoded from the QR code.
  static Future<void> handle(BuildContext context, String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return;

    final slug = _extractSlug(trimmed);

    if (slug != null && slug.isNotEmpty) {
      // ── MyCardShare link → open rich in-app profile view ────────────────
      if (!context.mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (ctx, animation, _) =>
              ScannedProfileViewScreen(cardSlug: slug),
          transitionsBuilder: (ctx, animation, _, child) {
            const curve = Curves.easeOutCubic;
            final tween =
                Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .chain(CurveTween(curve: curve));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } else {
      // ── External / unknown link → open in browser ───────────────────────
      await _launchUrl(context, trimmed);
    }
  }

  /// Returns the card slug if [url] belongs to the MyCardShare platform,
  /// null otherwise.
  static String? _extractSlug(String url) {
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return null;
    }

    final host = uri.host.toLowerCase().replaceAll('www.', '');
    final isDomain =
        _cardDomains.any((d) => host == d || host.endsWith('.$d'));

    if (!isDomain) return null;

    final path = uri.path;
    if (!path.startsWith(_cardPathPrefix)) return null;

    final slug = path.substring(_cardPathPrefix.length).split('/').first.trim();
    return slug.isEmpty ? null : slug;
  }

  /// Opens [url] in the external browser. Shows a snackbar on failure.
  static Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final canOpen = await canLaunchUrl(uri);
    if (canOpen) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open: $url'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}


