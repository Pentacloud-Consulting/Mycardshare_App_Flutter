import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'public_scanned_card_screen.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// ScannedCardChoiceModal
/// ────────────────────────────────────────────────────────────────────────────
/// Displayed when a user scans another person's digital business card QR code
/// or NFC tag. Prompts the user to choose between:
/// 1. "Open in App" (Rich native business card profile with direct VCF save,
///    Google & Samsung wallet, and interactive lead exchange)
/// 2. "Open in Web Browser" (Opens official public web card in Chrome / Safari)
class ScannedCardChoiceModal extends StatelessWidget {
  final String cardSlug;
  final String rawUrl;

  const ScannedCardChoiceModal({
    super.key,
    required this.cardSlug,
    required this.rawUrl,
  });

  /// Displays the interactive choice modal sheet
  static Future<void> show(
    BuildContext context, {
    required String cardSlug,
    required String rawUrl,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScannedCardChoiceModal(
        cardSlug: cardSlug,
        rawUrl: rawUrl,
      ),
    );
  }

  void _openInApp(BuildContext context) {
    Navigator.of(context).pop(); // dismiss modal
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicScannedCardScreen(cardSlug: cardSlug),
      ),
    );
  }

  Future<void> _openInWeb(BuildContext context) async {
    Navigator.of(context).pop(); // dismiss modal
    final targetUrl = rawUrl.startsWith('http')
        ? rawUrl
        : 'https://digitalbusinesscloudcard.com/card/$cardSlug';

    final uri = Uri.parse(targetUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[ScannedCardChoiceModal] Web launch note: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cannot open browser for: $targetUrl"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 28, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle pill
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Modal Header with Glowing QR Badge
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF0052FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Business Card Detected",
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cardSlug.isNotEmpty ? "card: $cardSlug" : "Digital Business Card",
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            const Text(
              "How would you like to view this business card profile?",
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // ── Option 1: Open in App (Recommended) ─────────────────────────
            InkWell(
              onTap: () => _openInApp(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.4),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.smartphone_rounded,
                        color: Color(0xFF16A34A),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Open in App",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(width: 8),
                              _BadgePill(text: "Recommended", color: Color(0xFF16A34A)),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Interactive card with 1-tap Save Contact (.VCF), Wallet & Exchange",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF16A34A)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Option 2: Open in Web Browser ──────────────────────────────
            InkWell(
              onTap: () => _openInWeb(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Color(0xFF0052FF),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Open in Web Browser",
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "View public card on digitalbusinesscloudcard.com in Chrome / browser",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel / Dismiss
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String text;
  final Color color;

  const _BadgePill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
