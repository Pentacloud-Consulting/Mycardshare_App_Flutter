import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../public_card/scanned_card_choice_modal.dart';
import '../../public_card/public_scanned_card_screen.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// QrRedirectHandler
/// ────────────────────────────────────────────────────────────────────────────
/// Called immediately after the device qr_scanner or NFC reads a code/url.
///
/// Decision logic:
///   • If the scanned URL is a MyCardShare card link
///     (`digitalbusinesscloudcard.com/card/<slug>`, `mycardshare.com/card/<slug>`, etc.)
///     prompts the user with [ScannedCardChoiceModal] to choose:
///       1. "Open in App" -> opens [PublicScannedCardScreen] (with auto-home redirect on back)
///       2. "Open in Web Browser" -> opens Chrome / browser
///   • If the person who SCANNED does NOT have the app (they scanned with phone camera),
///     they naturally open the web card page in Chrome/Safari via Android App Links.
///   • Any other URL (LinkedIn, website, etc.) is opened in the external browser.
class QrRedirectHandler {
  QrRedirectHandler._();

  /// Base domains that belong to the MyCardShare platform.
  static const _cardDomains = [
    'digitalbusinesscloudcard.com',
    'www.digitalbusinesscloudcard.com',
    'mycardshare.com',
    'www.mycardshare.com',
    'mycardshare.vercel.app',
    'localhost',
    '127.0.0.1',
  ];

  /// Determines the route and prompts or navigates accordingly.
  ///
  /// [rawUrl] — the raw string decoded from the QR code.
  static Future<void> handle(BuildContext context, String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return;

    final slug = _extractSlug(trimmed);

    if (slug != null && slug.isNotEmpty) {
      if (!context.mounted) return;

      // ⚡ Ask user whether to open inside App or in Web Browser
      await ScannedCardChoiceModal.show(
        context,
        cardSlug: slug,
        rawUrl: trimmed,
      );
    } else {
      // ── External / unknown link → open in browser ───────────────────────
      await _launchUrl(context, trimmed);
    }
  }

  /// Directly opens the rich in-app profile view without choice prompt
  static void openInAppDirectly(BuildContext context, String slug) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicScannedCardScreen(cardSlug: slug),
      ),
    );
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

    // Custom deep link scheme: mycardshare://card/<slug> or mycardshare://<slug>
    if (uri.scheme == 'mycardshare') {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last.trim();
      }
      if (uri.host.isNotEmpty && uri.host != 'card') {
        return uri.host.trim();
      }
    }

    final host = uri.host.toLowerCase().replaceAll('www.', '');
    final isDomain =
        _cardDomains.any((d) => host == d || host.endsWith('.$d'));

    if (!isDomain) {
      // Check if raw string is just a slug (no http/https)
      if (!url.startsWith('http://') && !url.startsWith('https://') && !url.contains('/')) {
        return url.trim();
      }
      return null;
    }

    final path = uri.path;
    if (path.startsWith('/card/')) {
      final slug = path.substring('/card/'.length).split('/').first.trim();
      return slug.isEmpty ? null : slug;
    }
    if (path.startsWith('/profile/')) {
      final slug = path.substring('/profile/'.length).split('/').first.trim();
      return slug.isEmpty ? null : slug;
    }
    if (path.startsWith('/company/')) {
      final slug = path.substring('/company/'.length).split('/').first.trim();
      return slug.isEmpty ? null : slug;
    }

    return null;
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
