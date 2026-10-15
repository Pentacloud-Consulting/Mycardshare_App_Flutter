import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../backend/individual/scan/scan_profile_view_service.dart';
import '../../enterprise/brand_profile/enterprise_scanned_card_screen.dart';
import '../user_view_card/scanned_profile_view_screen.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// QrRedirectHandler (Employee Module)
/// ────────────────────────────────────────────────────────────────────────────
/// Called immediately after the device qr_scanner reads a code.
///
/// Decision logic:
///   • If the scanned URL is a MyCardShare card/company link, we fetch the card
///     role via [ScanProfileViewService] and route to:
///     - [EnterpriseScannedCardScreen] if profileType == 'enterprise'
///     - [ScannedProfileViewScreen] if profileType == 'individual' or 'employee'
///   • External / non-card URLs are opened in the device browser.
class QrRedirectHandler {
  QrRedirectHandler._();

  static const _cardDomains = [
    'mycardshare.com',
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
      try {
        final cardData =
            await ScanProfileViewService.instance.fetchScannedProfile(slug);
        if (!context.mounted) return;

        if (cardData.profileType == 'enterprise') {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EnterpriseScannedCardScreen(cardSlug: slug),
            ),
          );
        } else {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (ctx, animation, _) =>
                  ScannedProfileViewScreen(cardSlug: slug),
              transitionsBuilder: (ctx, animation, _, child) {
                const curve = Curves.easeOutCubic;
                final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
                    .chain(CurveTween(curve: curve));
                return SlideTransition(
                    position: animation.drive(tween), child: child);
              },
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        }
      } catch (e) {
        debugPrint('[QrRedirectHandler] Fallback direct route for $slug: $e');
        if (!context.mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScannedProfileViewScreen(cardSlug: slug),
          ),
        );
      }
    } else {
      await _launchUrl(context, trimmed);
    }
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

    if (!isDomain) return null;

    final path = uri.path;
    if (path.startsWith('/card/')) {
      final slug = path.substring('/card/'.length).split('/').first.trim();
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
