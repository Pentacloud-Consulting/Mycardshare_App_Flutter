import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../backend/individual/scan_profile_view/scan_profile_view.dart';
import '../../backend/contact/save_contact_service.dart';
import '../../backend/individual/wallet/wallet_service.dart';
import '../../backend/individual/wallet/samsung_wallet.dart';
import '../../backend/individual/lead/active_lead.dart';
import '../../backend/individual/social_redirect/social_redirect_service.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// PublicScannedCardScreen
/// ────────────────────────────────────────────────────────────────────────────
/// Dedicated screen rendered whenever a user scans another person's digital
/// business card QR code / NFC tag or opens a shared card link.
///
/// Features:
/// 1. Visual fidelity matching the live Web card (Avatar, cover, bio, badges).
/// 2. Interactive action buttons:
///    - Save Contact (.VCF directly into phone contacts)
///    - Add to Google Wallet & Samsung Wallet
///    - Exchange Contact (Sends lead back to the card owner)
///    - Direct Phone, Email, WhatsApp, and Social links
/// 3. DETERMINISTIC CLOSE / GO-BACK REDIRECT:
///    When closed or back is pressed, immediately redirects the user to their
///    respective logged-in home interface (Master Admin, Enterprise, Employee,
///    or Individual Portal).
class PublicScannedCardScreen extends StatefulWidget {
  final String cardSlug;

  const PublicScannedCardScreen({
    super.key,
    required this.cardSlug,
  });

  @override
  State<PublicScannedCardScreen> createState() => _PublicScannedCardScreenState();
}

class _PublicScannedCardScreenState extends State<PublicScannedCardScreen> {
  late Future<PublicProfileData> _profileFuture;
  bool _isNavigatingHome = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = ScanProfileViewService.instance.fetchProfileBySlug(widget.cardSlug);
  }

  /// Resolves the user's logged-in role and navigates to their specific Home interface
  Future<void> _closeAndNavigateHome() async {
    if (_isNavigatingHome) return;
    _isNavigatingHome = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      final prefs = await SharedPreferences.getInstance();
      String role = prefs.getString('user_role')?.toLowerCase().replaceAll('_', '-') ?? '';

      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['isMasterAdmin'] == true) {
              role = 'master-admin';
            } else if (data['role'] != null) {
              role = (data['role'] as String).toLowerCase().replaceAll('_', '-');
            }
          }
        } catch (e) {
          debugPrint('[PublicScannedCardScreen] Role check note: $e');
        }
      }

      if (!mounted) return;

      String homeRoute;
      if (user == null && !(prefs.getBool('is_logged_in') ?? false)) {
        homeRoute = '/onboarding';
      } else if (role == 'master-admin') {
        homeRoute = '/master-admin/dashboard';
      } else if (role == 'enterprise') {
        homeRoute = '/enterprise/dashboard';
      } else {
        homeRoute = '/portal'; // Individual or Employee
      }

      context.go(homeRoute);
    } catch (e) {
      debugPrint('[PublicScannedCardScreen] Navigation error: $e');
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.go('/portal');
        }
      }
    }
  }

  void _onSaveContact(PublicProfileData profile) {
    SaveContactService.saveContactDirectly(
      context,
      fullName: profile.fullName,
      phone: profile.phone,
      email: profile.email,
      company: profile.company,
      jobTitle: profile.jobTitle,
      website: profile.website,
      bio: profile.bio,
      avatarUrl: profile.avatarUrl,
      cardSlug: profile.cardSlug,
    );
  }

  void _onAddToGoogleWallet(PublicProfileData profile) {
    WalletService.addToGoogleWallet(publicProfile: profile, context: context);
  }

  void _onAddToSamsungWallet(PublicProfileData profile) {
    SamsungWalletService.instance.saveToSamsungWallet(context, publicProfile: profile);
  }

  void _onExchangeContact(PublicProfileData profile) {
    ActiveLeadService.showLeadExchangeModal(context, profile: profile);
  }

  void _onShareCard(PublicProfileData profile) {
    final shareUrl = 'https://digitalbusinesscloudcard.com/card/${profile.cardSlug}';
    Clipboard.setData(ClipboardData(text: shareUrl));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text("Card link copied: $shareUrl")),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Intercept hardware/system back button and gestures
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _closeAndNavigateHome();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            tooltip: "Close and return to Home",
            onPressed: _closeAndNavigateHome,
          ),
          title: const Text(
            "Scanned Digital Card",
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Color(0xFF0052FF), size: 24),
              tooltip: "Go to Home",
              onPressed: _closeAndNavigateHome,
            ),
          ],
        ),
        body: FutureBuilder<PublicProfileData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0052FF)),
                    SizedBox(height: 16),
                    Text(
                      "Loading business card...",
                      style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.credit_card_off_rounded, size: 56, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 14),
                      const Text(
                        "Unable to load profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Card slug: ${widget.cardSlug}",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _closeAndNavigateHome,
                        icon: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
                        label: const Text("Return to Home"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final profile = snapshot.data!;
            return _buildCardContent(profile);
          },
        ),
      ),
    );
  }

  Widget _buildCardContent(PublicProfileData profile) {
    final initials = () {
      final clean = profile.fullName.trim();
      if (clean.isEmpty) return 'MC';
      final parts = clean.split(RegExp(r'\s+'));
      if (parts.length == 1) {
        return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        children: [
          // ── 1. Main Business Card Shell (Web Lookalike) ───────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Banner / Cover Header
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        image: profile.bannerUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(profile.bannerUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),

                    // Avatar Circle overlapping the banner
                    Positioned(
                      bottom: -46,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: profile.avatarUrl.isNotEmpty
                            ? Image.network(
                                profile.avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildAvatarFallback(initials),
                              )
                            : _buildAvatarFallback(initials),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 54),

                // Name & Badges
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              profile.fullName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: Color(0xFF0052FF), size: 20),
                        ],
                      ),

                      if (profile.jobTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.jobTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                      ],

                      if (profile.company.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.business_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                profile.company,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Networking Status Badge
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              profile.userStatus.isNotEmpty ? profile.userStatus : "Actively Networking",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bio / About Quote Card
                      if (profile.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            profile.bio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // ── Quick Communication Action Tiles ─────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (profile.phone.isNotEmpty)
                            _buildQuickActionCircle(
                              icon: Icons.phone_rounded,
                              label: "Call",
                              color: const Color(0xFF10B981),
                              onTap: () => SocialRedirectService.launchPhone(profile.phone, context: context),
                            ),
                          if (profile.email.isNotEmpty)
                            _buildQuickActionCircle(
                              icon: Icons.email_rounded,
                              label: "Email",
                              color: const Color(0xFF0052FF),
                              onTap: () => SocialRedirectService.launchEmail(profile.email, context: context),
                            ),
                          if (profile.phone.isNotEmpty)
                            _buildQuickActionCircle(
                              icon: Icons.chat_bubble_rounded,
                              label: "WhatsApp",
                              color: const Color(0xFF25D366),
                              onTap: () {
                                final clean = profile.phone.replaceAll(RegExp(r'[^\d]'), '');
                                final waUri = Uri.parse('https://wa.me/$clean');
                                launchUrl(waUri, mode: LaunchMode.externalApplication);
                              },
                            ),
                          if (profile.website.isNotEmpty)
                            _buildQuickActionCircle(
                              icon: Icons.language_rounded,
                              label: "Website",
                              color: const Color(0xFF8B5CF6),
                              onTap: () => SocialRedirectService.launchGenericUrl(profile.website, context: context),
                            ),
                        ],
                      ),

                      // Social Links Grid
                      if (profile.socialLinks.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFE2E8F0), height: 1),
                        const SizedBox(height: 14),
                        const Text(
                          "SOCIAL & CONNECT",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: profile.socialLinks.map((link) {
                            return InkWell(
                              onTap: () => SocialRedirectService.launchSocialPlatform(
                                platform: link.platform,
                                rawInput: link.url,
                                context: context,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getSocialIcon(link.platform),
                                      size: 15,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      link.platform,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 2. Primary Action Buttons (Save Contact, Wallet, Exchange) ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Save Contact Button
                ElevatedButton.icon(
                  onPressed: () => _onSaveContact(profile),
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    "Save Contact to Phone (.VCF)",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

                const SizedBox(height: 10),

                // Exchange Contact Modal
                OutlinedButton.icon(
                  onPressed: () => _onExchangeContact(profile),
                  icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF0052FF), size: 20),
                  label: const Text(
                    "Exchange Contact (Share Yours)",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0052FF)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.4),
                    backgroundColor: const Color(0xFFEFF6FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 14),

                // Digital Wallet Section
                const Text(
                  "DIGITAL WALLET PASS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    // Google Wallet
                    Expanded(
                      child: InkWell(
                        onTap: () => _onAddToGoogleWallet(profile),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wallet_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Google Wallet",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Samsung Wallet
                    Expanded(
                      child: InkWell(
                        onTap: () => _onAddToSamsungWallet(profile),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C20D6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.credit_card_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Samsung Wallet",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Share Card Link
                TextButton.icon(
                  onPressed: () => _onShareCard(profile),
                  icon: const Icon(Icons.share_rounded, size: 17, color: Color(0xFF64748B)),
                  label: const Text(
                    "Share Digital Business Card Link",
                    style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Return Home Floating Footer Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _closeAndNavigateHome,
              icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF475569)),
              label: const Text(
                "Close & Return to My Workspace",
                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569)),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(String initials) {
    return Container(
      color: const Color(0xFF0052FF),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuickActionCircle({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.work_outline_rounded;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'whatsapp':
        return Icons.chat_bubble_outline_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'youtube':
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.link_rounded;
    }
  }
}
