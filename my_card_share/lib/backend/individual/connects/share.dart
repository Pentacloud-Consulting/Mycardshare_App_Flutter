import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';

/// Backend service to handle real dynamic sharing of digital card profiles across platforms (WhatsApp, Email, SMS, Copy Link).
class ShareCardService {
  ShareCardService._internal();
  static final ShareCardService instance = ShareCardService._internal();

  /// Trigger real dynamic share popup or direct native share sheet
  Future<void> shareCard({
    BuildContext? context,
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    final activeProfile = profile ?? IndividualProfileStore.instance.activeProfile;

    final String name = publicProfile?.fullName ?? activeProfile?.fullName ?? 'Card Member';
    final String title = publicProfile?.jobTitle ?? activeProfile?.jobTitle ?? '';
    final String company = publicProfile?.company ?? activeProfile?.companyName ?? '';
    final String phone = publicProfile?.phone ?? activeProfile?.phoneNumber ?? '';
    final String email = publicProfile?.email ?? activeProfile?.email ?? '';
    final String cardSlug = publicProfile?.cardSlug ?? activeProfile?.cardSlug ?? 'card';
    final String cardUrl = 'https://mycardshare.com/card/$cardSlug';

    debugPrint('[ShareCardService] Sharing card for: $name ($cardUrl)');

    if (context != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => _ShareCardModalSheet(
          name: name,
          title: title,
          company: company,
          phone: phone,
          email: email,
          cardSlug: cardSlug,
          cardUrl: cardUrl,
        ),
      );
    }
  }
}

class _ShareCardModalSheet extends StatelessWidget {
  final String name;
  final String title;
  final String company;
  final String phone;
  final String email;
  final String cardSlug;
  final String cardUrl;

  const _ShareCardModalSheet({
    required this.name,
    required this.title,
    required this.company,
    required this.phone,
    required this.email,
    required this.cardSlug,
    required this.cardUrl,
  });

  String get _shareText {
    final buffer = StringBuffer();
    buffer.writeln('🎴 Digital Business Card - $name');
    if (title.isNotEmpty) {
      buffer.writeln('📌 $title${company.isNotEmpty ? ' at $company' : ''}');
    }
    buffer.writeln();
    buffer.writeln('🔗 View & Save Card: $cardUrl');
    if (phone.isNotEmpty) buffer.writeln('📞 Mobile: $phone');
    if (email.isNotEmpty) buffer.writeln('✉️ Email: $email');
    return buffer.toString();
  }

  Future<void> _shareToWhatsApp(BuildContext context) async {
    final encoded = Uri.encodeComponent(_shareText);
    final whatsappUrl = Uri.parse('https://api.whatsapp.com/send?text=$encoded');
    final whatsappAppUrl = Uri.parse('whatsapp://send?text=$encoded');

    try {
      if (await canLaunchUrl(whatsappAppUrl)) {
        await launchUrl(whatsappAppUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(context, message: 'Copied card info! Paste in WhatsApp.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(context, message: 'Copied card info to clipboard!');
      }
    }
  }

  Future<void> _shareToEmail(BuildContext context) async {
    final subject = Uri.encodeComponent('$name - Digital Business Card');
    final body = Uri.encodeComponent(_shareText);
    final mailtoUrl = Uri.parse('mailto:?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(mailtoUrl)) {
        await launchUrl(mailtoUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(context, message: 'Copied card info to email text!');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(context);
      }
    }
  }

  Future<void> _shareToSms(BuildContext context) async {
    final body = Uri.encodeComponent(_shareText);
    final smsUrl = Uri.parse('sms:?body=$body');

    try {
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(context);
      }
    }
  }

  void _copyToClipboard(BuildContext context, {String? message}) {
    Clipboard.setData(ClipboardData(text: cardUrl));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? "✓ Card link copied to clipboard!"),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.ios_share_rounded, color: Color(0xFF0052FF), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share $name\'s Card',
                      style: const TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cardUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Platform Share Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShareTile(
                icon: Icons.chat_bubble_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {
                  Navigator.pop(context);
                  _shareToWhatsApp(context);
                },
              ),
              _ShareTile(
                icon: Icons.mail_rounded,
                label: 'Email',
                color: const Color(0xFFEA4335),
                onTap: () {
                  Navigator.pop(context);
                  _shareToEmail(context);
                },
              ),
              _ShareTile(
                icon: Icons.sms_rounded,
                label: 'Message',
                color: const Color(0xFF0088FF),
                onTap: () {
                  Navigator.pop(context);
                  _shareToSms(context);
                },
              ),
              _ShareTile(
                icon: Icons.link_rounded,
                label: 'Copy Link',
                color: const Color(0xFF0052FF),
                onTap: () => _copyToClipboard(context),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}


