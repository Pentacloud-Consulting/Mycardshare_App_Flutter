import 'package:flutter/material.dart';
import '../../../features/Nav/portal_bottom_nav.dart';
import '../../../features/Nav/portal_top_nav.dart';
import '../../../features/individual/home/View My card/home.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/individual/multiple store/individual_multi_store.dart';
import '../../../backend/individual/qr scan/individual_qr_service.dart';

class IndividualCardScreen extends StatefulWidget {
  final String? slug;
  final bool showBottomNav;

  const IndividualCardScreen({
    super.key,
    this.slug,
    this.showBottomNav = true,
  });

  @override
  State<IndividualCardScreen> createState() => _IndividualCardScreenState();
}

class _IndividualCardScreenState extends State<IndividualCardScreen> {
  IndividualProfileData? _fetchedProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.slug != null && widget.slug!.trim().isNotEmpty) {
      _loadProfileBySlug(widget.slug!.trim());
    }
  }

  Future<void> _loadProfileBySlug(String slug) async {
    setState(() => _isLoading = true);
    final profile = await IndividualQRService.instance.fetchCardBySlug(slug);
    if (mounted) {
      setState(() {
        _fetchedProfile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IndividualProfileStore.instance,
      builder: (context, _) {
        final activeProfile = _fetchedProfile ?? IndividualProfileStore.instance.activeProfile;
        final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;

        final name = activeProfile?.fullName ?? storedUser?.fullName ?? "User";
        final role = activeProfile?.jobTitle.isNotEmpty == true ? activeProfile!.jobTitle : "Member";
        final company = activeProfile?.companyName.isNotEmpty == true ? activeProfile!.companyName : "MyCardShare Member";
        final status = activeProfile?.networkingStatus.isNotEmpty == true ? activeProfile!.networkingStatus : "ACTIVELY NETWORKING";
        final templateIndex = IndividualProfileStore.getTemplateIndex(activeProfile?.templateStyle);

        if (_isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFD),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0052FF)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          appBar: widget.showBottomNav ? PortalTopNav(userName: name.split(' ').first) : null,
          bottomNavigationBar: widget.showBottomNav ? const PortalBottomNav() : null,
          body: Stack(
            children: [
              // Soft baby-blue gradient ambient glow top right
              Positioned(
                top: -50,
                right: -50,
                child: IgnorePointer(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.7,
                        colors: [
                          const Color(0xFF38BDF8).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Header Banner with Overlapping Avatar & Info
                      CardHeaderBanner(
                        name: name,
                        role: role,
                        company: company,
                        status: status,
                        selectedTemplateIndex: templateIndex,
                        avatarUrl: activeProfile?.profilePhoto,
                        bannerUrl: activeProfile?.bannerPhoto,
                      ),

                      const SizedBox(height: 18),

                      // Quick Action Pill Buttons (Email & Call)
                      const CardQuickActions(),

                      const SizedBox(height: 14),

                      // Quote Bio Card
                      CardBioQuoteCard(
                        bio: activeProfile?.shortBio.isNotEmpty == true
                            ? activeProfile!.shortBio
                            : "Passionate about creating meaningful connections.",
                      ),

                      const SizedBox(height: 18),

                      // Social Icon Row
                      CardSocialRow(
                        links: activeProfile?.socialLinks,
                      ),

                      const SizedBox(height: 20),

                      // Save Contact, Secondary Buttons & Center QR Button
                      CardFooterActions(name: name),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
