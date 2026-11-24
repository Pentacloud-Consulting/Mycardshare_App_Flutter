import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../profile/enterprise_profile_store.dart';

/// Modern Multi-Platform Share Sheet for Enterprise Workspace Invites.
class WorkspaceInviteShareModal extends StatelessWidget {
  final String linkUrl;
  final String? inviteCode;
  final String? companyName;

  const WorkspaceInviteShareModal({
    super.key,
    required this.linkUrl,
    this.inviteCode,
    this.companyName,
  });

  String get _effectiveCompany {
    if (companyName != null && companyName!.trim().isNotEmpty) {
      return companyName!.trim();
    }
    final prof = EnterpriseProfileStore.instance.currentProfile;
    if (prof != null && prof.companyName.trim().isNotEmpty) {
      return prof.companyName.trim();
    }
    return "Our Enterprise Workspace";
  }

  String get _effectiveCode {
    if (inviteCode != null && inviteCode!.trim().isNotEmpty) {
      return inviteCode!.trim();
    }
    if (linkUrl.contains('code=')) {
      final parts = linkUrl.split('code=');
      if (parts.length > 1) {
        return parts[1].split('&').first;
      }
    }
    return "83063299";
  }

  String get _effectiveUrl {
    if (linkUrl.startsWith('http://') || linkUrl.startsWith('https://')) {
      return linkUrl;
    }
    return 'https://$linkUrl';
  }

  String get _shareText {
    final buffer = StringBuffer();
    buffer.writeln('🏢 You are invited to join $_effectiveCompany on MyCardShare!');
    buffer.writeln();
    buffer.writeln('🔑 Workspace Invite Code: $_effectiveCode');
    buffer.writeln('🔗 Direct Join Link: $_effectiveUrl');
    buffer.writeln();
    buffer.writeln('Enter this code in MyCardShare to claim your digital business card and start networking today!');
    return buffer.toString();
  }

  Future<void> _shareToWhatsApp(BuildContext context) async {
    final encoded = Uri.encodeComponent(_shareText);
    final whatsappAppUrl = Uri.parse('whatsapp://send?text=$encoded');
    final whatsappWebUrl = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      if (await canLaunchUrl(whatsappAppUrl)) {
        await launchUrl(whatsappAppUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(context, message: 'Invite copied! Paste in WhatsApp.');
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(context, message: 'Invite copied to clipboard!');
      }
    }
  }

  Future<void> _shareToEmail(BuildContext context) async {
    final subject = Uri.encodeComponent('Invitation to join $_effectiveCompany on MyCardShare');
    final body = Uri.encodeComponent(_shareText);
    final mailtoUrl = Uri.parse('mailto:?subject=$subject&body=$body');

    try {
      if (await canLaunchUrl(mailtoUrl)) {
        await launchUrl(mailtoUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(context, message: 'Invite copied to email draft!');
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

  Future<void> _shareToTelegram(BuildContext context) async {
    final encodedUrl = Uri.encodeComponent(_effectiveUrl);
    final encodedText = Uri.encodeComponent('Join $_effectiveCompany on MyCardShare with code: $_effectiveCode');
    final tgUrl = Uri.parse('https://t.me/share/url?url=$encodedUrl&text=$encodedText');

    try {
      if (await canLaunchUrl(tgUrl)) {
        await launchUrl(tgUrl, mode: LaunchMode.externalApplication);
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

  Future<void> _shareNative(BuildContext context) async {
    try {
      await Share.share(
        _shareText,
        subject: 'Join $_effectiveCompany on MyCardShare',
      );
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(context);
      }
    }
  }

  void _copyToClipboard(BuildContext context, {String? message}) {
    Clipboard.setData(ClipboardData(text: _shareText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message ?? "✓ Workspace invite code & link copied to clipboard!",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFD4642C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                color: const Color(0xFFCBD5E1),
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
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Color(0xFFD4642C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share Workspace Invite',
                      style: TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code: $_effectiveCode • $_effectiveCompany',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Code Pill Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFFD4642C),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Invite Code: $_effectiveCode",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _effectiveCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Code $_effectiveCode copied!"),
                        backgroundColor: const Color(0xFFD4642C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded,
                            size: 12, color: Color(0xFFD4642C)),
                        SizedBox(width: 4),
                        Text(
                          "Copy Code",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4642C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Primary Platform Grid Row 1 (WhatsApp, Email, Message, Telegram)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShareAppTile(
                icon: Icons.chat_bubble_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {
                  Navigator.pop(context);
                  _shareToWhatsApp(context);
                },
              ),
              _ShareAppTile(
                icon: Icons.mail_rounded,
                label: 'Email',
                color: const Color(0xFFEA4335),
                onTap: () {
                  Navigator.pop(context);
                  _shareToEmail(context);
                },
              ),
              _ShareAppTile(
                icon: Icons.sms_rounded,
                label: 'SMS',
                color: const Color(0xFF0284C7),
                onTap: () {
                  Navigator.pop(context);
                  _shareToSms(context);
                },
              ),
              _ShareAppTile(
                icon: Icons.send_rounded,
                label: 'Telegram',
                color: const Color(0xFF0088CC),
                onTap: () {
                  Navigator.pop(context);
                  _shareToTelegram(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Action Buttons Row 2 (Native Share & Copy Full Invite)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF7ED),
                      foregroundColor: const Color(0xFFD4642C),
                      elevation: 0,
                      side: const BorderSide(
                          color: Color(0xFFFED7AA), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _shareNative(context);
                    },
                    icon: Icon(Icons.adaptive.share, size: 18),
                    label: const Text(
                      'More Options',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4642C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      _copyToClipboard(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text(
                      'Copy Invite',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _ShareAppTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareAppTile({
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
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
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
