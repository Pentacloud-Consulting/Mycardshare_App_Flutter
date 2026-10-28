import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../public_card/scanned_card_choice_modal.dart';
import '../../public_card/public_scanned_card_screen.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// QrRedirectHandler (Employee Module)
/// ────────────────────────────────────────────────────────────────────────────
/// Called immediately after the device qr_scanner reads a code in Employee module.
class QrRedirectHandler {
  QrRedirectHandler._();

  static const _cardDomains = [
    'digitalbusinesscloudcard.com',
    'www.digitalbusinesscloudcard.com',
    'mycardshare.com',
    'www.mycardshare.com',
    'mycardshare.vercel.app',
    'localhost',
    '127.0.0.1',
  ];

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

  static void openInAppDirectly(BuildContext context, String slug) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicScannedCardScreen(cardSlug: slug),
      ),
    );
  }

  static String? _extractSlug(String url) {
    Uri? uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return null;
    }

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
