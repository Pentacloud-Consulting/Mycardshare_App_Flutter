import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Backend service for Vault contact actions: Call, SMS/Message, Email, Copy, and Real Social Platform Card Sharing.
class VaultShareService {
  VaultShareService._internal();
  static final VaultShareService instance = VaultShareService._internal();

  /// Sanitize phone number for tel/sms URI
  String sanitizePhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Triggers real phone call via native dialer
  Future<void> makeCall(BuildContext context, String rawPhone) async {
    final phone = rawPhone.trim();
    if (phone.isEmpty || phone == '—') {
      _showSnack(context, '⚠ No phone number available', isError: true);
      return;
    }

    final clean = sanitizePhoneNumber(phone);
    final Uri uri = Uri.parse('tel:$clean');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        await copyToClipboard(context, phone, 'Phone number');
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, phone, 'Phone number');
    }
  }

  /// Triggers SMS message or WhatsApp chat
  Future<void> sendMessage(BuildContext context, String rawPhone) async {
    final phone = rawPhone.trim();
    if (phone.isEmpty || phone == '—') {
      _showSnack(context, '⚠ No phone number available', isError: true);
      return;
    }

    final clean = sanitizePhoneNumber(phone);
    final Uri smsUri = Uri.parse('sms:$clean');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        final Uri waUri = Uri.parse('https://wa.me/$clean');
        if (await canLaunchUrl(waUri)) {
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
        } else {
          if (!context.mounted) return;
          await copyToClipboard(context, phone, 'Phone number');
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, phone, 'Phone number');
    }
  }

  /// Triggers real email compose
  Future<void> sendEmail(BuildContext context, String rawEmail, {String? contactName}) async {
    final email = rawEmail.trim();
    if (email.isEmpty || email == '—' || !email.contains('@')) {
      _showSnack(context, '⚠ No valid email available', isError: true);
      return;
    }

    final subject = Uri.encodeComponent('Connecting with ${contactName ?? 'you'}');
    final Uri uri = Uri.parse('mailto:$email?subject=$subject');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        await copyToClipboard(context, email, 'Email address');
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, email, 'Email address');
    }
  }

  /// Copies text to system clipboard with a smooth feedback message
  Future<void> copyToClipboard(BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      _showSnack(context, '✓ $label copied to clipboard!');
    }
  }

  /// Generates a clean, beautifully formatted digital business card text block.
  String generateCardFormattedText({
    required String name,
    required String role,
    required String company,
    required String phone,
    required String email,
    String? website,
    String? address,
    String? tag,
  }) {
    final slug = name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '-');
    final buf = StringBuffer();

    buf.writeln('🎴 DIGITAL BUSINESS CARD');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('👤 Name: $name');
    if (role.isNotEmpty) buf.writeln('💼 Role: $role');
    if (company.isNotEmpty) buf.writeln('🏢 Company: $company');
    buf.writeln('');
    if (phone.isNotEmpty && phone != '—') buf.writeln('📞 Phone: $phone');
    if (email.isNotEmpty && email != '—') buf.writeln('✉️ Email: $email');
    if (website != null && website.isNotEmpty && website != '—') buf.writeln('🌐 Web: $website');
    if (address != null && address.isNotEmpty && address != '—') buf.writeln('📍 Location: $address');
    buf.writeln('');
    buf.writeln('✨ Shared via My Card Share');
    buf.writeln('🔗 Digital Card: https://mycardshare.app/v/$slug');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buf.toString();
  }

  // ── Social Platform Share Launchers ────────────────────────────────────────

  /// Real WhatsApp Share
  Future<void> shareToWhatsApp(BuildContext context, String cardText) async {
    final encoded = Uri.encodeComponent(cardText);
    final Uri waUri = Uri.parse('whatsapp://send?text=$encoded');
    final Uri waWebUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      if (await canLaunchUrl(waUri)) {
        await launchUrl(waUri);
      } else if (await canLaunchUrl(waWebUri)) {
        await launchUrl(waWebUri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        await copyToClipboard(context, cardText, 'Card info (WhatsApp app not installed)');
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, cardText, 'Card info');
    }
  }

  /// Real Telegram Share
  Future<void> shareToTelegram(BuildContext context, String cardText) async {
    final encoded = Uri.encodeComponent(cardText);
    final Uri tgUri = Uri.parse('tg://msg?text=$encoded');
    final Uri tgWebUri = Uri.parse('https://t.me/share/url?text=$encoded');

    try {
      if (await canLaunchUrl(tgUri)) {
        await launchUrl(tgUri);
      } else if (await canLaunchUrl(tgWebUri)) {
        await launchUrl(tgWebUri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        await copyToClipboard(context, cardText, 'Card info (Telegram app not installed)');
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, cardText, 'Card info');
    }
  }

  /// Real SMS Share
  Future<void> shareToSms(BuildContext context, String cardText) async {
    final encoded = Uri.encodeComponent(cardText);
    final Uri smsUri = Uri.parse('sms:?body=$encoded');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (!context.mounted) return;
        await copyToClipboard(context, cardText, 'Card info');
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, cardText, 'Card info');
    }
  }

  /// Real Email Share
  Future<void> shareToEmail(BuildContext context, String cardText, String name) async {
    final subject = Uri.encodeComponent('Business Card: $name');
    final body = Uri.encodeComponent(cardText);
    final Uri emailUri = Uri.parse('mailto:?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (!context.mounted) return;
        await copyToClipboard(context, cardText, 'Card info');
      }
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, cardText, 'Card info');
    }
  }

  /// Native System Share Sheet
  Future<void> shareToSystem(BuildContext context, String cardText, String name) async {
    try {
      await Share.share(cardText, subject: '$name - Business Card');
    } catch (e) {
      if (!context.mounted) return;
      await copyToClipboard(context, cardText, 'Card info');
    }
  }

  /// Opens the real card sharing modal with direct social platform targets (WhatsApp, Telegram, SMS, Email, System Share)
  Future<void> shareContactCard(
    BuildContext context, {
    required String name,
    required String role,
    required String company,
    required String phone,
    required String email,
    String? website,
    String? address,
    String? tag,
  }) async {
    final cardText = generateCardFormattedText(
      name: name,
      role: role,
      company: company,
      phone: phone,
      email: email,
      website: website,
      address: address,
      tag: tag,
    );

    _showSharePreviewModal(context, cardText: cardText, name: name);
  }

  /// Modal dialog showing formatted card preview + real social sharing buttons
  void _showSharePreviewModal(BuildContext context, {required String cardText, required String name}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.share_rounded, color: Color(0xFF0052FF), size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Share $name\'s Card',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Card Layout Preview Box
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.35,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        cardText,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: Color(0xFF334155),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Section Label: Real Social Platform Sharing
                const Text(
                  'SHARE TO PLATFORM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),

                // Social Platforms Grid Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // WhatsApp
                    _buildSocialPlatformButton(
                      context,
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                      brandColor: const Color(0xFF25D366),
                      onTap: () {
                        Navigator.pop(ctx);
                        shareToWhatsApp(context, cardText);
                      },
                    ),

                    // Telegram
                    _buildSocialPlatformButton(
                      context,
                      icon: FontAwesomeIcons.telegram,
                      label: 'Telegram',
                      brandColor: const Color(0xFF229ED9),
                      onTap: () {
                        Navigator.pop(ctx);
                        shareToTelegram(context, cardText);
                      },
                    ),

                    // SMS
                    _buildSocialPlatformButton(
                      context,
                      icon: Icons.sms_rounded,
                      label: 'SMS',
                      brandColor: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pop(ctx);
                        shareToSms(context, cardText);
                      },
                    ),

                    // Email
                    _buildSocialPlatformButton(
                      context,
                      icon: Icons.mail_rounded,
                      label: 'Email',
                      brandColor: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.pop(ctx);
                        shareToEmail(context, cardText, name);
                      },
                    ),

                    // More Apps (System Share Sheet)
                    _buildSocialPlatformButton(
                      context,
                      icon: Icons.ios_share_rounded,
                      label: 'More Apps',
                      brandColor: const Color(0xFF6366F1),
                      onTap: () {
                        Navigator.pop(ctx);
                        shareToSystem(context, cardText, name);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Copy Card Text Button (Secondary Action)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      copyToClipboard(context, cardText, 'Card info');
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.copy_rounded, color: Color(0xFF0052FF), size: 18),
                    label: const Text(
                      'Copy Card Text',
                      style: TextStyle(color: Color(0xFF0052FF), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget building social platform icon buttons
  Widget _buildSocialPlatformButton(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required Color brandColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: brandColor.withValues(alpha: 0.3), width: 1.2),
            ),
            child: Center(
              child: icon is IconData
                  ? Icon(icon, color: brandColor, size: 22)
                  : FaIcon(icon, color: brandColor, size: 20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
