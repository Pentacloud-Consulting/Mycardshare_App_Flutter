import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';
import '../../../../backend/individual/scan_profile_view/scan_profile_view.dart';
import '../../../../backend/individual/lead/active_lead.dart';
import '../../../../backend/individual/connects/save_contact.dart';
import '../../../../backend/individual/connects/share.dart';
import '../home/View My card/card_footer_actions.dart';
import '../../../../backend/individual/social_redirect/social_redirect_service.dart';

/// ────────────────────────────────────────────────────────────────────────────
/// ScannedProfileViewScreen
/// ────────────────────────────────────────────────────────────────────────────
/// Opens when the scanner reads a MyCardShare QR code and the scanned user's
/// card data is fetched from the backend.  Renders a complete, polished
/// in-app business card profile — identical visual quality to the web card
/// page so both experiences feel consistent.
///
/// Launched by [QrRedirectHandler.handle].
class ScannedProfileViewScreen extends StatefulWidget {
  final String cardSlug;

  const ScannedProfileViewScreen({super.key, required this.cardSlug});

  @override
  State<ScannedProfileViewScreen> createState() =>
      _ScannedProfileViewScreenState();
}

class _ScannedProfileViewScreenState extends State<ScannedProfileViewScreen>
    with TickerProviderStateMixin {
  late Future<PublicProfileData> _profileFuture;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _profileFuture = ScanProfileViewService.instance
        .fetchProfileBySlug(widget.cardSlug)
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

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _launchEmail(String email) async {
    await SocialRedirectService.launchEmail(email, context: context);
  }

  Future<void> _launchPhone(String phone) async {
    await SocialRedirectService.launchPhone(phone, context: context);
  }

  Future<void> _launchUrl(String url) async {
    await SocialRedirectService.launchGenericUrl(url, context: context);
  }

  void _copyLink(String slug) {
    Clipboard.setData(
        ClipboardData(text: 'https://mycardshare.com/card/$slug'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Card link copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exchangeContact(PublicProfileData profile) {
    ActiveLeadService.showLeadExchangeModal(context, profile: profile);
  }

  // ── Social platform icon helper ────────────────────────────────────────────

  IconData _socialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.work_outline_rounded;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'whatsapp':
        return Icons.chat_bubble_outline_rounded;
      case 'youtube':
        return Icons.play_circle_outline_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'facebook':
        return Icons.facebook_rounded;
      case 'pinterest':
        return Icons.push_pin_rounded;
      case 'telegram':
        return Icons.send_rounded;
      case 'website':
        return Icons.language_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  Color _socialColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'twitter':
      case 'x':
        return const Color(0xFF000000);
      case 'instagram':
        return const Color(0xFFE1306C);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'github':
        return const Color(0xFF181717);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'pinterest':
        return const Color(0xFFBD081C);
      case 'telegram':
        return const Color(0xFF26A5E4);
      default:
        return const Color(0xFF0052FF);
    }
  }

  // ── Theme color from hex ────────────────────────────────────────────────────

  Color _themeColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF0052FF);
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FutureBuilder<PublicProfileData>(
        future: _profileFuture,
        builder: (context, snap) {
          // ── Loading ──────────────────────────────────────────────────────
          if (snap.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          // ── Error ────────────────────────────────────────────────────────
          if (snap.hasError || !snap.hasData) {
            return _ErrorView(slug: widget.cardSlug);
          }

          final profile = snap.data!;
          final themeColor = _themeColor(profile.themeColor);

          return FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              slivers: [
                // ── Sticky header with banner + avatar ───────────────────
                SliverToBoxAdapter(
                  child: _BannerSection(
                    profile: profile,
                    themeColor: themeColor,
                    onBack: () => Navigator.of(context).pop(),
                    onShare: () => _copyLink(profile.cardSlug),
                  ),
                ),

                // ── Body content ─────────────────────────────────────────
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),

                      // Name / title / company
                      _NameSection(profile: profile, themeColor: themeColor),

                      const SizedBox(height: 20),

                      // Quick action pills (Email / Call / Website)
                      _QuickActions(
                        profile: profile,
                        onEmail: () => _launchEmail(profile.email),
                        onCall: () => _launchPhone(profile.phone),
                        onWeb: () => _launchUrl(profile.website),
                      ),

                      const SizedBox(height: 20),

                      // Bio / quote
                      if (profile.bio.isNotEmpty) ...[
                        _BioBubble(bio: profile.bio),
                        const SizedBox(height: 20),
                      ],

                      // Social links grid
                      if (profile.socialLinks.isNotEmpty) ...[
                        _SectionLabel(label: 'Connect'),
                        const SizedBox(height: 12),
                        _SocialGrid(
                          links: profile.socialLinks,
                          iconFor: _socialIcon,
                          colorFor: _socialColor,
                          onTap: (url) => _launchUrl(url),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Dynamic Scanned View Actions (Save Contact + Share Card + QR + Exchange Contact)
                      CardFooterActions(
                        name: profile.fullName,
                        isOwnerView: false,
                        showBranding: false,
                        onSaveContactTap: () async {
                          final contactData = ContactExportData.fromPublicProfile(profile);
                          final success = await SaveContactService.instance.saveContactToPhone(contactData);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? "✓ Exported ${profile.fullName} to mobile contacts!"
                                      : "Contact details: ${profile.fullName} (${profile.phone})",
                                ),
                                backgroundColor: themeColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        onShareTap: () => ShareCardService.instance.shareCard(
                          context: context,
                          publicProfile: profile,
                        ),
                        onExchangeContactTap: () => _exchangeContact(profile),
                      ),

                      const SizedBox(height: 32),

                      // Footer
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
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: Color(0xFF0052FF), strokeWidth: 2.5),
            const SizedBox(height: 16),
            Text(
              'Loading profile…',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String slug;
  const _ErrorView({required this.slug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.person_search_rounded,
                    color: Color(0xFF0052FF), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile not found',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                'No card found for "@$slug". The user may not have set up their profile yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0052FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Go Back',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  final PublicProfileData profile;
  final Color themeColor;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _BannerSection({
    required this.profile,
    required this.themeColor,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // ── Banner background ──────────────────────────────────────────────
        SizedBox(
          height: 210,
          width: double.infinity,
          child: profile.bannerUrl.isNotEmpty
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      profile.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _GradientBanner(themeColor: themeColor),
                    ),
                    // Frosted overlay for readability
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        color: themeColor.withAlpha(50),
                      ),
                    ),
                  ],
                )
              : _GradientBanner(themeColor: themeColor),
        ),

        // ── Back & Share buttons overlay ─────────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GlassButton(icon: Icons.arrow_back_ios_rounded, onTap: onBack),
              _GlassButton(icon: Icons.ios_share_rounded, onTap: onShare),
            ],
          ),
        ),

        // ── Networking status badge ──────────────────────────────────────
        if (profile.userStatus.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                      radius: 4, backgroundColor: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    profile.userStatus.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Avatar overlapping the banner bottom ─────────────────────────
        Positioned(
          bottom: -52,
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 16,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ClipOval(
              child: profile.avatarUrl.isNotEmpty
                  ? Image.network(
                      profile.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _InitialsAvatar(name: profile.fullName),
                    )
                  : _InitialsAvatar(name: profile.fullName),
            ),
          ),
        ),

        // Spacer so the card body gives room for the overlapping avatar
        const SizedBox(height: 50),
      ],
    );
  }
}

class _GradientBanner extends StatelessWidget {
  final Color themeColor;
  const _GradientBanner({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final lighter = Color.lerp(themeColor, Colors.white, 0.3) ?? themeColor;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor, lighter],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(60),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
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
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    return Container(
      color: const Color(0xFFEFF6FF),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0052FF)),
      ),
    );
  }
}

class _NameSection extends StatelessWidget {
  final PublicProfileData profile;
  final Color themeColor;
  const _NameSection({required this.profile, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 52), // space for the overlapping avatar
        Text(
          profile.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.1),
        ),
        if (profile.jobTitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            profile.jobTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: themeColor),
          ),
        ],
        if (profile.company.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            profile.company,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
          ),
        ],
        if (profile.cardSlug.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'mycardshare.com/card/${profile.cardSlug}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade400,
                letterSpacing: 0.2),
          ),
        ],
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final PublicProfileData profile;
  final VoidCallback onEmail;
  final VoidCallback onCall;
  final VoidCallback onWeb;

  const _QuickActions({
    required this.profile,
    required this.onEmail,
    required this.onCall,
    required this.onWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (profile.email.isNotEmpty)
          Expanded(
            child: _ActionPill(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                onTap: onEmail),
          ),
        if (profile.email.isNotEmpty && profile.phone.isNotEmpty)
          const SizedBox(width: 10),
        if (profile.phone.isNotEmpty)
          Expanded(
            child: _ActionPill(
                icon: Icons.phone_outlined, label: 'Call', onTap: onCall),
          ),
        if (profile.website.isNotEmpty &&
            (profile.email.isNotEmpty || profile.phone.isNotEmpty))
          const SizedBox(width: 10),
        if (profile.website.isNotEmpty)
          Expanded(
            child: _ActionPill(
                icon: Icons.language_rounded, label: 'Website', onTap: onWeb),
          ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionPill(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF0F172A)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BioBubble extends StatelessWidget {
  final String bio;
  const _BioBubble({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded,
              color: Color(0xFF38BDF8), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              bio,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2),
    );
  }
}

class _SocialGrid extends StatelessWidget {
  final List<SocialLinkItem> links;
  final IconData Function(String platform) iconFor;
  final Color Function(String platform) colorFor;
  final void Function(String url) onTap;

  const _SocialGrid({
    required this.links,
    required this.iconFor,
    required this.colorFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
      children: links.map((link) {
        final color = colorFor(link.platform);
        return GestureDetector(
          onTap: () {
            SocialRedirectService.launchSocialPlatform(
              platform: link.platform,
              rawInput: link.url,
              context: context,
            );
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(iconFor(link.platform), color: color, size: 16),
                const SizedBox(width: 7),
                Text(
                  link.platform,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );
  }
}


