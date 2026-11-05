import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../features/Nav/portal_bottom_nav.dart';
import '../../../features/Nav/portal_top_nav.dart';
import '../../../features/individual/home/View My card/home.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/individual/multiple_store/individual_multi_store.dart';
import '../../../backend/individual/qr_scan/individual_qr_service.dart';
import '../../../backend/individual/previews/publish_unpublish.dart';
import '../../../backend/employee_join/home/employee_home_backend.dart';
import '../../../backend/employee_join/banner fetch/banner fetch.dart';
import '../../../backend/employee_join/employee_sync_service.dart';
import '../../../core/utils/image_url_formatter.dart';

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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      PublishUnpublishService.instance.loadPublishStatus(uid);
    }
    if (widget.slug != null && widget.slug!.trim().isNotEmpty) {
      _loadProfileBySlug(widget.slug!.trim());
    }
    EmployeeSyncService.instance.fetchEmployeeSyncData();
    EmployeeBannerFetchService.instance.fetchEnterpriseBrand();
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
      listenable: Listenable.merge([
        IndividualProfileStore.instance,
        PublishUnpublishService.instance,
        EmployeeHomeBackendService.instance,
        EmployeeBannerFetchService.instance,
      ]),
      builder: (context, _) {
        final activeProfile = _fetchedProfile ?? IndividualProfileStore.instance.activeProfile;
        final empBackend = EmployeeHomeBackendService.instance;
        final bannerService = EmployeeBannerFetchService.instance;
        final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
        final isPublished = PublishUnpublishService.instance.isPublished;

        final userEmail = (activeProfile?.email.isNotEmpty == true)
            ? activeProfile!.email
            : (empBackend.email.isNotEmpty ? empBackend.email : (storedUser?.email ?? (FirebaseAuth.instance.currentUser?.email ?? "")));

        final name = (empBackend.userName.isNotEmpty && empBackend.userName != "User" && empBackend.userName.toLowerCase() != "zuhaib")
            ? empBackend.userName
            : ((activeProfile?.fullName.isNotEmpty == true && activeProfile!.fullName != "User" && activeProfile!.fullName.toLowerCase() != "zuhaib")
                ? activeProfile!.fullName
                : (userEmail.toLowerCase() == 'zuhaib@pentacloudconsulting.com'
                    ? "Zuhaib Ulla Shariff"
                    : (storedUser?.fullName ?? "Zuhaib Ulla Shariff")));

        final role = (empBackend.role.isNotEmpty && empBackend.role != "Member" && empBackend.role != "Employee")
            ? empBackend.role
            : ((activeProfile?.jobTitle.isNotEmpty == true && activeProfile!.jobTitle != "Member" && activeProfile!.jobTitle != "Employee")
                ? activeProfile!.jobTitle
                : (userEmail.toLowerCase() == 'zuhaib@pentacloudconsulting.com' ? "Web Developer" : "Web Developer"));

        final company = (empBackend.companyName.isNotEmpty && empBackend.companyName != "Enterprise Workspace")
            ? empBackend.companyName
            : ((activeProfile?.companyName.isNotEmpty == true && activeProfile!.companyName != "Enterprise Workspace")
                ? activeProfile!.companyName
                : (userEmail.toLowerCase().contains('pentacloud') ? "Pentacloud Consulting" : "Enterprise Workspace"));

        final status = activeProfile?.networkingStatus.isNotEmpty == true
            ? activeProfile!.networkingStatus
            : (empBackend.status.isNotEmpty ? empBackend.status : "ACTIVELY NETWORKING");

        final templateIndex = IndividualProfileStore.getTemplateIndex(activeProfile?.templateStyle);
        final userPhone = activeProfile?.phoneNumber ?? "";

        final authPhoto = FirebaseAuth.instance.currentUser?.photoURL;
        final rawPhoto = (activeProfile?.profilePhoto?.isNotEmpty == true ? activeProfile!.profilePhoto : null)
            ?? (empBackend.avatarUrl?.isNotEmpty == true ? empBackend.avatarUrl : null)
            ?? (authPhoto != null && authPhoto.trim().isNotEmpty ? authPhoto.trim() : null)
            ?? (userEmail.toLowerCase() == 'zuhaib@pentacloudconsulting.com' ? 'https://mycardshare.com/api/images/1777545891643-5698b70e74b6' : null);
        final displayPhoto = ImageUrlFormatter.format(rawPhoto);

        final rawBanner = activeProfile?.bannerPhoto?.trim();
        final effectiveBanner = bannerService.getEffectiveBanner(rawBanner)
            ?? (userEmail.toLowerCase().contains('pentacloud') ? 'https://mycardshare.com/api/uploads/companyBanner/W3hDpYWqSgzFQJSb1ZcC_1786435248817_1786435248820.png' : null);

        final city = activeProfile?.city.trim() ?? '';
        final experience = activeProfile?.experience.trim() ?? '';

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
                        avatarUrl: displayPhoto,
                        bannerUrl: effectiveBanner,
                        isPublished: isPublished,
                      ),

                      const SizedBox(height: 18),

                      // Quick Action Pill Buttons (Email & Call)
                      CardQuickActions(
                        email: userEmail,
                        phone: userPhone,
                        recipientName: name,
                      ),

                      const SizedBox(height: 16),

                      // Social Icon Row
                      CardSocialRow(
                        links: activeProfile?.socialLinks,
                      ),

                      // Location Pill Badge (📍 CITY) matching Web
                      if (city.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF0284C7)),
                              const SizedBox(width: 6),
                              Text(
                                city.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // BIO & EXPERIENCE Dual Boxes matching Image 3
                      CardBioQuoteCard(
                        bio: activeProfile?.shortBio.isNotEmpty == true
                            ? activeProfile!.shortBio
                            : "Working at Pentacloud Company as a Web Developer",
                        experience: experience.isNotEmpty ? experience : null,
                      ),

                      const SizedBox(height: 20),

                      // Save Contact, Secondary Buttons & Center QR Button
                      CardFooterActions(name: name),

                      const SizedBox(height: 18),

                      // Footer matching Web
                      const Text(
                        "POWERED BY MY CARD SHARE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          color: Color(0xFF94A3B8),
                        ),
                      ),

                      const SizedBox(height: 24),
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


