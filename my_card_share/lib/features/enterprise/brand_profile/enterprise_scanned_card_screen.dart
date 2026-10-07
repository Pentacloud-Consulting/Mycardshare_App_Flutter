import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_card_share/backend/enterprise/profile/enterprise_profile_store.dart';
import 'package:my_card_share/backend/enterprise/qr_scan/enterprice_qr_service.dart';
import 'package:my_card_share/backend/enterprise/qr_scan/enterprice_generate_qr.dart';
import 'package:my_card_share/backend/individual/connects/save_contact.dart';
import 'package:my_card_share/backend/individual/connects/share.dart';
import 'package:my_card_share/backend/individual/previews/publish_unpublish.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// EnterpriseScannedCardScreen
/// ────────────────────────────────────────────────────────────────────────────
/// Dedicated Enterprise Business Card View Screen.
/// 
/// 1. Top Banner: NO overlay back arrow, NO mock "Actively Networking" pill,
///    NO overlay share button. Clean banner + overlapping company logo.
/// 2. Quick Actions: Divided into two equal pills — "Email" and "Contact" (Call).
/// 3. Footer Actions: "Save Contact", "Share Card", and "qr_scan".
///    "qr_scan" triggers EnterpriseGenerateQR.showModal from lib/backend/enterprise/qr_scan/
class EnterpriseScannedCardScreen extends StatefulWidget {
  final String cardSlug;

  const EnterpriseScannedCardScreen({super.key, required this.cardSlug});

  @override
  State<EnterpriseScannedCardScreen> createState() =>
      _EnterpriseScannedCardScreenState();
}

class _EnterpriseScannedCardScreenState
    extends State<EnterpriseScannedCardScreen>
    with TickerProviderStateMixin {
  late Future<EnterpriseProfileData?> _profileFuture;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _profileFuture = EnterpriseQRService.instance
        .fetchCardBySlug(widget.cardSlug)
        .then((p) {
      _fadeCtrl.forward();
      return p;
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) return;
    final uri = Uri.parse('mailto:${email.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showToast('Could not open email app for $email');
    }
  }

  Future<void> _launchPhone(String phone) async {
    if (phone.trim().isEmpty) return;
    final uri = Uri.parse('tel:${phone.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showToast('Could not initiate call to $phone');
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.trim().isEmpty) return;
    var formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }
    final uri = Uri.tryParse(formatted);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: ListenableBuilder(
        listenable: PublishUnpublishService.instance,
        builder: (context, _) {
          final isPublished = PublishUnpublishService.instance.isPublished;

          return FutureBuilder<EnterpriseProfileData?>(
            future: _profileFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0052FF)),
                );
              }

              final profile = snap.data ?? EnterpriseProfileStore.instance.currentProfile;
              if (profile == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business_center_outlined,
                          size: 64, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text(
                        'Enterprise Card "@${widget.cardSlug}" Not Found',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                );
              }

              final companyName = profile.companyName.isNotEmpty
                  ? profile.companyName
                  : 'Enterprise Company';
              final email = profile.email;
              final phone = profile.phoneNumber;
              final website = profile.website;
              final bannerUrl = profile.bannerUrl ?? '';
              final logoUrl = profile.logoUrl ?? '';
              final slug = profile.cardSlug.isNotEmpty
                  ? profile.cardSlug
                  : widget.cardSlug;

              return FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      // ── Top Banner Container ──
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Banner image / gradient
                          Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: (bannerUrl.isEmpty)
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF0052FF),
                                        Color(0xFF7C3AED),
                                        Color(0xFF38BDF8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              image: (bannerUrl.isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(bannerUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),

                          // Active / Inactive Status Badge on top right of Banner
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isPublished
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPublished
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 3.5,
                                    backgroundColor: isPublished
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isPublished ? "ACTIVE" : "UNPUBLISHED",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isPublished
                                          ? const Color(0xFF047857)
                                          : const Color(0xFFB45309),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating Logo Avatar over banner
                          Positioned(
                            bottom: -44,
                            child: Container(
                              width: 88,
                              height: 88,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: (logoUrl.isNotEmpty)
                                    ? Image.network(
                                        logoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            _InitialsAvatar(name: companyName),
                                      )
                                    : _InitialsAvatar(name: companyName),
                              ),
                            ),
                          ),
                        ],
                      ),

                  const SizedBox(height: 54),

                  // ── Company Name & Subtitle Section ───────────────────────
                  Text(
                    companyName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.industry.isNotEmpty
                        ? profile.industry
                        : 'enterprise',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                  if (profile.shortBio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.shortBio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                  if (slug.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'mycardshare.com/card/$slug',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ── Quick Actions Row: Divided into 2 equal pills (Email & Contact) ──
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionPill(
                          icon: Icons.mail_outline_rounded,
                          label: 'Email',
                          onTap: () => _launchEmail(email),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionPill(
                          icon: Icons.phone_outlined,
                          label: 'Contact',
                          onTap: () => _launchPhone(phone),
                        ),
                      ),
                      if (website.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionPill(
                            icon: Icons.language_rounded,
                            label: 'Website',
                            onTap: () => _launchUrl(website),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Save Contact Primary Button ────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF0088FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x350052FF),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final contactData = ContactExportData(
                            fullName: companyName,
                            phoneNumber: phone,
                            emailAddress: email,
                            companyName: companyName,
                            jobTitle: profile.industry,
                            websiteUrl: website,
                            shortBio: profile.shortBio,
                          );
                          final success = await SaveContactService.instance
                              .saveContactToPhone(contactData);
                          _showToast(success
                              ? "Exported $companyName to mobile contacts!"
                              : "Contact details: $companyName ($phone)");
                        },
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.white, size: 22),
                        label: const Text(
                          "Save Contact",
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Secondary Action Row: "Share Card" & "qr_scan" ────────
                  Row(
                    children: [
                      // Share Card Button
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0052FF), Color(0xFF0088FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x300052FF),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => ShareCardService.instance.shareCard(
                                context: context,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.ios_share_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Share Card",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // qr_scan Button (Triggers EnterpriseGenerateQR.showModal)
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0052FF), Color(0xFF0088FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x300052FF),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => EnterpriseGenerateQR.showModal(
                                context,
                                cardSlug: slug,
                                name: companyName,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_scanner_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "qr_scan",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Footer Branding
                  Center(
                    child: Text(
                      'Powered by MyCardShare',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
);
  }
}

class _QuickActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF0052FF)),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'E';
    return Container(
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0052FF),
        ),
      ),
    );
  }
}

