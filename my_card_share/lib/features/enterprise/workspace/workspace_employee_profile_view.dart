import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../backend/enterprise/home_backend/employees_page.dart';
import '../../../backend/enterprise/workspace/workspace_employee_view.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../public_card/public_card_screen.dart';

/// Full Frontend Screen for viewing any particular enterprise employee profile.
/// Accurately loads real data from Firestore via [WorkspaceEmployeeViewService].
/// Accurately displays whether the employee has signed in, filled nothing, or whatever data has been filled.
class WorkspaceEmployeeProfileView extends StatefulWidget {
  final EnterpriseEmployeeModel? employee;
  final String? employeeId;
  final String? employeeEmail;
  final String? employeeName;
  final String? enterpriseUid;

  const WorkspaceEmployeeProfileView({
    super.key,
    this.employee,
    this.employeeId,
    this.employeeEmail,
    this.employeeName,
    this.enterpriseUid,
  });

  @override
  State<WorkspaceEmployeeProfileView> createState() =>
      _WorkspaceEmployeeProfileViewState();
}

class _WorkspaceEmployeeProfileViewState
    extends State<WorkspaceEmployeeProfileView> {
  bool _isBasicInfoExpanded = true;
  bool _isContactDetailsExpanded = true;
  bool _isLoading = true;
  WorkspaceEmployeeProfileData? _profileData;

  String get _effectiveEnterpriseUid {
    if (widget.enterpriseUid != null && widget.enterpriseUid!.isNotEmpty) {
      return widget.enterpriseUid!;
    }
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String get _effectiveEmployeeId {
    if (widget.employee != null && widget.employee!.id.isNotEmpty) {
      return widget.employee!.id;
    }
    if (widget.employeeId != null && widget.employeeId!.isNotEmpty) {
      return widget.employeeId!;
    }
    return '';
  }

  String get _effectiveEmployeeEmail {
    if (widget.employee != null && widget.employee!.email.isNotEmpty) {
      return widget.employee!.email;
    }
    return widget.employeeEmail ?? '';
  }

  String get _effectiveEmployeeName {
    if (widget.employee != null && widget.employee!.name.isNotEmpty) {
      return widget.employee!.name;
    }
    return widget.employeeName ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final entUid = _effectiveEnterpriseUid;
    final empId = _effectiveEmployeeId;
    final empEmail = _effectiveEmployeeEmail;
    final empName = _effectiveEmployeeName;

    // Record the profile view in background
    if (entUid.isNotEmpty && empId.isNotEmpty) {
      WorkspaceEmployeeViewService.instance.recordEmployeeProfileView(
        enterpriseUid: entUid,
        employeeId: empId,
        employeeEmail: empEmail,
        employeeName: empName,
      );
    }

    final data =
        await WorkspaceEmployeeViewService.instance.fetchEmployeeProfileDetails(
      enterpriseUid: entUid,
      employeeId: empId,
      employeeEmail: empEmail,
      employeeName: empName,
    );

    if (mounted) {
      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrlString(String urlStr) async {
    if (urlStr.trim().isEmpty) return;
    try {
      final uri = Uri.parse(
          urlStr.startsWith('http') ? urlStr : 'https://$urlStr');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Could not open: $urlStr"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _launchEmail(String email) async {
    if (email.trim().isEmpty) return;
    final uri = Uri(scheme: 'mailto', path: email);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _launchPhone(String phone) async {
    if (phone.trim().isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Background soft ambient gradient blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.16),
                    const Color(0xFF0052FF).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Top Custom App Bar matching Image 1
                _buildTopAppBar(context),

                // 2. Scrollable Body
                Expanded(
                  child: _isLoading && _profileData == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0052FF),
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFF0052FF),
                          onRefresh: _loadProfileData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hero Card Preview
                                _buildHeroCardPreview(_profileData!),

                                const SizedBox(height: 18),

                                // Quick Action Buttons (View Card & Share Card)
                                _buildActionButtonsRow(_profileData!),

                                const SizedBox(height: 20),

                                // CRITICAL: Dynamic Status & Onboarding Alert Banner
                                // Handles: Not signed in, Signed in but filled nothing, or Profile filled
                                _buildEmployeeStatusBanner(_profileData!),

                                const SizedBox(height: 20),

                                // Live Metrics Row (Views & Leads)
                                _buildLiveMetricsRow(_profileData!),

                                const SizedBox(height: 20),

                                // Basic Information Section
                                _buildBasicInfoSection(_profileData!),

                                const SizedBox(height: 20),

                                // Contact Details Section
                                _buildContactDetailsSection(_profileData!),

                                const SizedBox(height: 20),

                                // Social Links Section
                                _buildSocialLinksSection(_profileData!),

                                const SizedBox(height: 20),

                                // Digital Card Link Section (Slug)
                                _buildCardSlugSection(_profileData!),

                                const SizedBox(height: 20),

                                // Enterprise Brand Banner Management
                                _buildBrandBannerSection(_profileData!),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Top App Bar (Matches Image 1 style)
  // ---------------------------------------------------------------------------
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button matching Image 1
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                try {
                  context.go('/enterprise/workspace');
                } catch (_) {
                  Navigator.of(context).maybePop();
                }
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Employee Profile",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    _profileData?.name != null && _profileData!.name.isNotEmpty
                        ? _profileData!.name
                        : (_effectiveEmployeeName.isNotEmpty
                            ? _effectiveEmployeeName
                            : "Workspace Member"),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Options Menu Button
          PopupMenuButton<String>(
            icon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF475569),
                size: 20,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            onSelected: (action) async {
              if (_profileData == null) return;
              final data = _profileData!;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              if (action == 'view_card') {
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => PublicCardScreen(
                      slug: data.cardSlug,
                      showBottomNav: false,
                    ),
                  ),
                );
              } else if (action == 'copy_slug') {
                final link =
                    "https://mycardshare.com/card/${data.cardSlug}";
                await Clipboard.setData(ClipboardData(text: link));
                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Card link copied to clipboard!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF0052FF),
                    ),
                  );
                }
              } else if (action == 'toggle_banner') {
                final newLock = !data.isBannerLocked;
                await WorkspaceEmployeeViewService.instance.toggleBannerLock(
                  enterpriseUid: data.enterpriseUid,
                  employeeId: data.employeeId,
                  locked: newLock,
                );
                await _loadProfileData();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(newLock
                          ? "Brand banner locked for ${data.name}"
                          : "Brand banner unlocked for ${data.name}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else if (action == 'toggle_status') {
                final isCurrentlyActive = data.status.toLowerCase() == 'active';
                final newStatus = isCurrentlyActive ? 'Inactive' : 'Active';
                final settingInactive = isCurrentlyActive;

                await WorkspaceEmployeeViewService.instance.updateEmployeeDetails(
                  enterpriseUid: data.enterpriseUid,
                  employeeId: data.employeeId,
                  employeeUid: data.uid,
                  updates: {
                    'status': newStatus,
                    'isPublished': !settingInactive,
                    'adminSetInactive': settingInactive,
                  },
                );
                await _loadProfileData();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("${data.name} is now $newStatus"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: settingInactive ? const Color(0xFF64748B) : const Color(0xFF16A34A),
                    ),
                  );
                }
              } else if (action == 'toggle_role') {
                final newRole = data.isAdmin ? 'Employee' : 'Admin';
                await WorkspaceEmployeeViewService.instance.updateEmployeeDetails(
                  enterpriseUid: data.enterpriseUid,
                  employeeId: data.employeeId,
                  employeeUid: data.uid,
                  updates: {'role': newRole},
                );
                await _loadProfileData();
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Role updated to $newRole for ${data.name}"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else if (action == 'resend_invite') {
                await WorkspaceEmployeeViewService.instance.resendEmployeeInvite(
                  enterpriseUid: data.enterpriseUid,
                  email: data.email,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Invitation resent to ${data.email}!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF0052FF),
                    ),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_card',
                child: Row(
                  children: [
                    Icon(Icons.visibility_rounded,
                        color: Color(0xFF0052FF), size: 18),
                    SizedBox(width: 10),
                    Text("View Public Card"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy_slug',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded,
                        color: Color(0xFF0F172A), size: 18),
                    SizedBox(width: 10),
                    Text("Copy Card Link"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_banner',
                child: Row(
                  children: [
                    Icon(
                      _profileData?.isBannerLocked == true
                          ? Icons.lock_open_rounded
                          : Icons.lock_rounded,
                      color: const Color(0xFF0052FF),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(_profileData?.isBannerLocked == true
                        ? "Unlock Brand Banner"
                        : "Lock Brand Banner"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      _profileData?.status.toLowerCase() == 'active'
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      color: _profileData?.status.toLowerCase() == 'active'
                          ? const Color(0xFF64748B)
                          : const Color(0xFF16A34A),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(_profileData?.status.toLowerCase() == 'active'
                        ? "Mark as Inactive"
                        : "Mark as Active"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_role',
                child: Row(
                  children: [
                    Icon(
                      _profileData?.isAdmin == true
                          ? Icons.person_rounded
                          : Icons.shield_rounded,
                      color: const Color(0xFF9333EA),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(_profileData?.isAdmin == true
                        ? "Make Regular Employee"
                        : "Promote to Admin"),
                  ],
                ),
              ),
              if (_profileData?.isPending == true)
                const PopupMenuItem(
                  value: 'resend_invite',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_unread_rounded,
                          color: Color(0xFFD97706), size: 18),
                      SizedBox(width: 10),
                      Text("Resend Invite Email"),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Hero Live Card Preview
  // ---------------------------------------------------------------------------
  Widget _buildHeroCardPreview(WorkspaceEmployeeProfileData profile) {
    final gradientColors = _getTemplateGradient(profile.templateIndex);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Top section with Template Gradient
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Stack(
              children: [
                // Custom banner image if provided
                if (profile.bannerUrl != null &&
                    profile.bannerUrl!.trim().isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(22)),
                    child: _buildBannerImage(profile.bannerUrl!),
                  ),

                // Top right status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: profile.isPending
                                ? const Color(0xFFFBBF24)
                                : (profile.status.toLowerCase() == 'inactive' ||
                                        profile.status.toLowerCase() == 'deactivated')
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          profile.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Overlapping Avatar + Profile Info
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              children: [
                // Avatar positioned overlapping banner
                Transform.translate(
                  offset: const Offset(0, -32),
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: profile.isAdmin
                          ? const Color(0xFFF3E8FF)
                          : const Color(0xFFE0F2FE),
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarContent(profile),
                    ),
                  ),
                ),

                // Name & Role Title (Adjusted spacing due to avatar transform)
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.4,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Role Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: profile.isAdmin
                                  ? const Color(0xFFF3E8FF)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              profile.role,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: profile.isAdmin
                                    ? const Color(0xFF9333EA)
                                    : const Color(0xFF0052FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Job Title + Company
                      Text(
                        "${profile.roleTitle} · ${profile.companyName}",
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Networking Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profile.networkingStatus.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(WorkspaceEmployeeProfileData profile) {
    if (profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty) {
      final p = profile.avatarUrl!.trim();
      if (p.startsWith('data:image')) {
        try {
          final commaIdx = p.indexOf(',');
          final b64 = commaIdx != -1 ? p.substring(commaIdx + 1) : p;
          return Image.memory(base64Decode(b64), fit: BoxFit.cover);
        } catch (_) {}
      } else if (p.startsWith('http')) {
        return Image.network(
          p,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => _buildFallbackInitials(profile),
        );
      }
    }
    return _buildFallbackInitials(profile);
  }

  Widget _buildFallbackInitials(WorkspaceEmployeeProfileData profile) {
    return Center(
      child: Text(
        profile.initials,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: profile.isAdmin
              ? const Color(0xFF9333EA)
              : const Color(0xFF0052FF),
        ),
      ),
    );
  }

  Widget _buildBannerImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final b64 = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        return Image.memory(base64Decode(b64),
            width: double.infinity, height: 110, fit: BoxFit.cover);
      } catch (_) {}
    } else if (url.startsWith('http')) {
      return Image.network(url,
          width: double.infinity, height: 110, fit: BoxFit.cover);
    }
    return const SizedBox();
  }

  List<Color> _getTemplateGradient(int templateIndex) {
    switch (templateIndex) {
      case 1:
        return const [Color(0xFF833AB4), Color(0xFFC13584)];
      case 2:
        return const [Color(0xFF0D9488), Color(0xFF2DD4BF)];
      case 3:
        return const [Color(0xFF0F172A), Color(0xFF334155)];
      case 4:
        return const [Color(0xFF64748B), Color(0xFF94A3B8)];
      case 0:
      default:
        return const [Color(0xFF0052FF), Color(0xFF38BDF8)];
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Action Buttons Row (View Card & Share Card)
  // ---------------------------------------------------------------------------
  Widget _buildActionButtonsRow(WorkspaceEmployeeProfileData profile) {
    return Row(
      children: [
        // View Card Button
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x300052FF),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PublicCardScreen(
                      slug: profile.cardSlug,
                      showBottomNav: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_rounded,
                  color: Colors.white, size: 19),
              label: const Text(
                "View Card",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Share Card Button
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x300284C7),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                final link =
                    "https://mycardshare.com/card/${profile.cardSlug}";
                await Clipboard.setData(ClipboardData(text: link));
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Copied card link for ${profile.name}!"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF0284C7),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.share_rounded,
                  color: Colors.white, size: 18),
              label: const Text(
                "Share Card",
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CRITICAL: Dynamic Status & Onboarding Alert Banner
  // "if any employee have not signing the id and not filled any data...
  //  show 'particular email id' and text 'employee have not signed'
  //  or 'particular email id' and text 'employee have filled nothing'
  //  or whatever have been filled that should be shown"
  // ---------------------------------------------------------------------------
  Widget _buildEmployeeStatusBanner(WorkspaceEmployeeProfileData profile) {
    // CASE 1: Employee has NOT signed in / registered
    if (!profile.hasSignedIn) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB), // Soft Amber 50
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08D97706),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_unread_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "PENDING SIGN-UP",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Employee has not signed in",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Particular Email Highlight Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF78350F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              "The employee at ${profile.email} has not yet registered or signed into their account. Once they accept the invitation and sign in, their live profile will automatically connect.",
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFB45309),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Resend Invite Action Button
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await WorkspaceEmployeeViewService.instance
                      .resendEmployeeInvite(
                    enterpriseUid: profile.enterpriseUid,
                    email: profile.email,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Invitation resent to ${profile.email}!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFD97706),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.send_rounded,
                    size: 15, color: Colors.white),
                label: const Text(
                  "Resend Invitation Email",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // CASE 2: Employee has signed in, but has filled nothing
    if (profile.hasSignedIn && !profile.hasFilledData) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF), // Soft Sky Blue 50
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBAE6FD), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x080284C7),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "ACCOUNT SIGNED · DETAILS PENDING",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0369A1),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Employee has filled nothing yet",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0C4A6E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Particular Email Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 16, color: Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.email,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0C4A6E),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              "The employee at ${profile.email} is signed in, but has not completed their card details (bio, phone number, website, or social links) yet.",
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0369A1),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),

            // Missing checklist tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: profile.missingFields.map((f) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_circle_outline_rounded,
                          size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        f,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    final isInactive = profile.status.toLowerCase() == 'inactive' ||
        profile.status.toLowerCase() == 'deactivated';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isInactive ? const Color(0xFFF8FAFC) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInactive ? const Color(0xFFCBD5E1) : const Color(0xFFBBF7D0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isInactive ? const Color(0xFFE2E8F0) : const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isInactive ? Icons.pause_circle_filled_rounded : Icons.verified_rounded,
                color: isInactive ? const Color(0xFF64748B) : const Color(0xFF16A34A),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isInactive ? const Color(0xFF334155) : const Color(0xFF166534),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isInactive
                      ? "Profile Inactive · ${profile.filledFieldsCount} details filled"
                      : "Profile Active · ${profile.filledFieldsCount} details completed",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isInactive ? const Color(0xFF64748B) : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isInactive ? const Color(0xFFE2E8F0) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isInactive ? "INACTIVE" : "ACTIVE",
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isInactive ? const Color(0xFF64748B) : const Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Live Metrics Row (Views, Leads, Status)
  // ---------------------------------------------------------------------------
  Widget _buildLiveMetricsRow(WorkspaceEmployeeProfileData profile) {
    return Row(
      children: [
        // Views Card
        Expanded(
          child: _buildMetricCard(
            title: "Views",
            value: "${profile.views}",
            icon: Icons.visibility_rounded,
            iconColor: const Color(0xFF0052FF),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),

        // Leads Card
        Expanded(
          child: _buildMetricCard(
            title: "Leads",
            value: "${profile.leads}",
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF7C3AED),
            bgColor: const Color(0xFFF5F3FF),
          ),
        ),
        const SizedBox(width: 10),

        // Status Card
        Expanded(
          child: Builder(
            builder: (context) {
              final isInactive = profile.status.toLowerCase() == 'inactive' ||
                  profile.status.toLowerCase() == 'deactivated';
              final color = profile.isPending
                  ? const Color(0xFFD97706)
                  : isInactive
                      ? const Color(0xFF64748B)
                      : const Color(0xFF16A34A);
              final bg = profile.isPending
                  ? const Color(0xFFFEF9C3)
                  : isInactive
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFFDCFCE7);

              return _buildMetricCard(
                title: "Status",
                value: profile.status,
                icon: Icons.circle,
                iconColor: color,
                bgColor: bg,
                isSmallValue: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    bool isSmallValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallValue ? 13 : 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Basic Information Section
  // ---------------------------------------------------------------------------
  Widget _buildBasicInfoSection(WorkspaceEmployeeProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Basic Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            _buildSmallExpandButton(
              isExpanded: _isBasicInfoExpanded,
              onTap: () {
                setState(() => _isBasicInfoExpanded = !_isBasicInfoExpanded);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildViewCard(
          children: [
            _buildViewRow(Icons.person_rounded, "Full Name", profile.name),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(
                      Icons.work_rounded, "Job Title", profile.roleTitle),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(
                      Icons.business_rounded, "Company", profile.companyName),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  _buildViewRow(
                    Icons.edit_note_rounded,
                    "Bio",
                    profile.hasBio ? profile.shortBio : "No bio filled yet.",
                    isMultiLine: true,
                    isPlaceholder: !profile.hasBio,
                  ),
                ],
              ),
              crossFadeState: _isBasicInfoExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 260),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Contact Details Section
  // ---------------------------------------------------------------------------
  Widget _buildContactDetailsSection(WorkspaceEmployeeProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Contact Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            _buildSmallExpandButton(
              isExpanded: _isContactDetailsExpanded,
              onTap: () {
                setState(() =>
                    _isContactDetailsExpanded = !_isContactDetailsExpanded);
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildViewCard(
          children: [
            GestureDetector(
              onTap: () => _launchEmail(profile.email),
              child: _buildViewRow(
                Icons.email_rounded,
                "Email",
                profile.email.isNotEmpty
                    ? profile.email
                    : "No email provided",
                actionWidget: profile.email.isNotEmpty
                    ? const Icon(Icons.arrow_outward_rounded,
                        size: 16, color: Color(0xFF0052FF))
                    : null,
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                children: [
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  GestureDetector(
                    onTap: profile.hasPhone
                        ? () => _launchPhone(profile.phoneNumber)
                        : null,
                    child: _buildViewRow(
                      Icons.phone_rounded,
                      "Phone",
                      profile.hasPhone
                          ? profile.phoneNumber
                          : "Not provided yet",
                      isPlaceholder: !profile.hasPhone,
                      actionWidget: profile.hasPhone
                          ? const Icon(Icons.call_rounded,
                              size: 16, color: Color(0xFF0052FF))
                          : null,
                    ),
                  ),
                  const Divider(color: Color(0xFFF1F5F9), height: 24),
                  GestureDetector(
                    onTap: profile.hasWebsite
                        ? () => _launchUrlString(profile.websiteUrl)
                        : null,
                    child: _buildViewRow(
                      Icons.language_rounded,
                      "Website",
                      profile.hasWebsite
                          ? profile.websiteUrl
                          : "Not provided yet",
                      isPlaceholder: !profile.hasWebsite,
                      actionWidget: profile.hasWebsite
                          ? const Icon(Icons.open_in_new_rounded,
                              size: 16, color: Color(0xFF0052FF))
                          : null,
                    ),
                  ),
                ],
              ),
              crossFadeState: _isContactDetailsExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 260),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 8. Social Links Section
  // ---------------------------------------------------------------------------
  Widget _buildSocialLinksSection(WorkspaceEmployeeProfileData profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Social Links",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        if (profile.socialLinks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.link_off_rounded,
                    color: Color(0xFF94A3B8), size: 20),
                SizedBox(width: 8),
                Text(
                  "No social links added yet by employee.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: profile.socialLinks.map((item) {
                return _buildSocialPill(item);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialPill(SocialLinkItem item) {
    Widget iconWidget = const Icon(Icons.link_rounded, size: 14, color: Color(0xFF0052FF));

    final platform = item.platform.toLowerCase();
    if (platform.contains('linkedin')) {
      iconWidget = const FaIcon(FontAwesomeIcons.linkedin, size: 14, color: Color(0xFF0A66C2));
    } else if (platform.contains('twitter') || platform.contains('x')) {
      iconWidget = const FaIcon(FontAwesomeIcons.xTwitter, size: 14, color: Color(0xFF0F1419));
    } else if (platform.contains('github')) {
      iconWidget = const FaIcon(FontAwesomeIcons.github, size: 14, color: Color(0xFF24292E));
    } else if (platform.contains('instagram')) {
      iconWidget = const FaIcon(FontAwesomeIcons.instagram, size: 14, color: Color(0xFFE1306C));
    } else if (platform.contains('facebook')) {
      iconWidget = const FaIcon(FontAwesomeIcons.facebook, size: 14, color: Color(0xFF1877F2));
    } else if (platform.contains('youtube')) {
      iconWidget = const FaIcon(FontAwesomeIcons.youtube, size: 14, color: Color(0xFFFF0000));
    }

    return GestureDetector(
      onTap: () => _launchUrlString(item.url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              item.platform,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_outward_rounded,
                size: 13, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. Card Link (Slug) Section
  // ---------------------------------------------------------------------------
  Widget _buildCardSlugSection(WorkspaceEmployeeProfileData profile) {
    final fullUrl = "https://mycardshare.com/card/${profile.cardSlug}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Card Link",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        _buildViewCard(
          children: [
            Row(
              children: [
                const Icon(Icons.link_rounded,
                    size: 20, color: Color(0xFF0052FF)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Public Card URL",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fullUrl,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0052FF),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      size: 18, color: Color(0xFF64748B)),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: fullUrl));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Link copied to clipboard!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 10. Brand Banner Lock Section
  // ---------------------------------------------------------------------------
  Widget _buildBrandBannerSection(WorkspaceEmployeeProfileData profile) {
    return _buildViewCard(
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: profile.isBannerLocked
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  profile.isBannerLocked
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  color: profile.isBannerLocked
                      ? const Color(0xFF0052FF)
                      : const Color(0xFF64748B),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enterprise Brand Banner",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    profile.isBannerLocked
                        ? "Locked by Enterprise"
                        : "Unlocked (Employee can change)",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: profile.isBannerLocked
                          ? const Color(0xFF0052FF)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: profile.isBannerLocked,
              activeThumbColor: const Color(0xFF0052FF),
              onChanged: (val) async {
                await WorkspaceEmployeeViewService.instance.toggleBannerLock(
                  enterpriseUid: profile.enterpriseUid,
                  employeeId: profile.employeeId,
                  locked: val,
                );
                await _loadProfileData();
              },
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Widgets
  // ---------------------------------------------------------------------------
  Widget _buildViewCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSmallExpandButton({
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:
              isExpanded ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isExpanded ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? "Collapse" : "Expand",
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isExpanded
                    ? const Color(0xFF0052FF)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: isExpanded
                  ? const Color(0xFF0052FF)
                  : const Color(0xFF64748B),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewRow(
    IconData icon,
    String label,
    String value, {
    bool isMultiLine = false,
    bool isPlaceholder = false,
    Widget? actionWidget,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0052FF)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPlaceholder
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                  fontStyle:
                      isPlaceholder ? FontStyle.italic : FontStyle.normal,
                  height: isMultiLine ? 1.4 : 1.0,
                ),
              ),
            ],
          ),
        ),
        if (actionWidget != null) ...[
          const SizedBox(width: 8),
          actionWidget,
        ],
      ],
    );
  }
}

/// Backwards compatibility alias for existing routes
typedef ProfileViewScreen = WorkspaceEmployeeProfileView;
