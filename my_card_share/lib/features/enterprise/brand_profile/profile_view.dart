import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_card_share/backend/enterprise/profile/enterprise_profile_store.dart';
import 'package:my_card_share/backend/enterprise/invite_employee/invite_link.dart';
import 'package:my_card_share/backend/individual/previews/publish_unpublish.dart';
import 'package:my_card_share/backend/enterprise/view_employee/view_employee.dart';
import 'enterprise_scanned_card_screen.dart';
import 'widgets/brand_slug.dart';

/// Enterprise Profile View Card Screen (mirrors Individual Profile View Screen).
/// Displays real cover banner, company logo, live card preview, and enterprise info.
class EnterpriseProfileViewScreen extends StatefulWidget {
  const EnterpriseProfileViewScreen({super.key});

  @override
  State<EnterpriseProfileViewScreen> createState() =>
      _EnterpriseProfileViewScreenState();
}

class _EnterpriseProfileViewScreenState
    extends State<EnterpriseProfileViewScreen> {
  bool _isBasicInfoExpanded = false;
  bool _isContactDetailsExpanded = false;
  bool _isSocialExpanded = false;
  final GlobalKey _publishBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      PublishUnpublishService.instance.loadPublishStatus(uid);
    }
  }

  Future<void> _launchUrl(String urlString) async {
    if (urlString.trim().isEmpty) return;
    var formatted = urlString.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }
    final uri = Uri.tryParse(formatted);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }


  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: ListenableBuilder(
        listenable: PublishUnpublishService.instance,
        builder: (context, _) {
          final isPublished = PublishUnpublishService.instance.isPublished;

          return StreamBuilder<EnterpriseProfileData?>(
            stream: uid.isNotEmpty
                ? EnterpriseProfileStore.instance.profileStream(uid)
                : const Stream.empty(),
            builder: (context, snapshot) {
              final profile =
                  snapshot.data ?? EnterpriseProfileStore.instance.currentProfile;

              final companyName = profile?.companyName ?? 'Enterprise Company';
              final email = profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';
              final logoUrl = profile?.logoUrl;
              final bannerUrl = profile?.bannerUrl;
              final industry = profile?.industry.isNotEmpty == true
                  ? profile!.industry
                  : 'Corporate & Business Services';
              final plan = profile?.plan ?? 'free';
              final employeeCount = profile?.employeeCount ?? 1;
              final website = profile?.website ?? '';
              final phone = profile?.phoneNumber ?? '';
              final address = profile?.address ?? '';
              final bio = profile?.shortBio.isNotEmpty == true
                  ? profile!.shortBio
                  : 'Official Enterprise Organization Profile.';
              final slug = profile?.cardSlug ??
                  EnterpriseProfileData.generateCardSlug(companyName);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Live Enterprise Card Preview Box ─────────────────────────────
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Banner Box
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(22),
                                  ),
                                  gradient: (bannerUrl == null || bannerUrl.isEmpty)
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
                                  image: (bannerUrl != null && bannerUrl.isNotEmpty)
                                      ? DecorationImage(
                                          image: NetworkImage(bannerUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              ),

                              // Floating Active / Inactive Highlight Status Badge over Banner
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
                                        isPublished ? "ACTIVE" : "INACTIVE",
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

                              // Floating Company Logo Avatar over Banner
                              Positioned(
                                bottom: -32,
                                left: 20,
                                child: Container(
                                  width: 76,
                                  height: 76,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: (logoUrl != null && logoUrl.isNotEmpty)
                                        ? Image.network(logoUrl, fit: BoxFit.cover)
                                        : Container(
                                            color: const Color(0xFFEFF6FF),
                                            child: const Icon(
                                              Icons.apartment_rounded,
                                              color: Color(0xFF0052FF),
                                              size: 38,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 42),

                          // Company Information Summary
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  companyName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  industry,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0052FF),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPublished
                                            ? const Color(0xFFEFF4FF)
                                            : const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isPublished
                                            ? '${plan[0].toUpperCase()}${plan.substring(1)} Plan · Active'
                                            : '${plan[0].toUpperCase()}${plan.substring(1)} Plan · Inactive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isPublished
                                              ? const Color(0xFF0052FF)
                                              : const Color(0xFFB45309),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Live count from Firestore
                                    const EnterpriseEmployeeCountBadge(),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  bio,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF475569),
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 18),
                               ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Action Buttons Row (Publish/Unpublish Toggle & View Card) ────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isPublished
                                    ? [const Color(0xFF0052FF), const Color(0xFF38BDF8)]
                                    : [const Color(0xFFD97706), const Color(0xFFF59E0B)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: isPublished
                                      ? const Color(0xFF0052FF).withValues(alpha: 0.25)
                                      : const Color(0xFFD97706).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              key: _publishBtnKey,
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final navOverlay = Navigator.of(context).overlay;
                                if (navOverlay == null) return;

                                final RenderBox button = _publishBtnKey.currentContext!.findRenderObject() as RenderBox;
                                final RenderBox overlay = navOverlay.context.findRenderObject() as RenderBox;
                                final RelativeRect position = RelativeRect.fromRect(
                                  Rect.fromPoints(
                                    button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
                                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                                  ),
                                  Offset.zero & overlay.size,
                                );

                                final value = await showMenu<bool>(
                                  context: context,
                                  position: position,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  items: [
                                    const PopupMenuItem(
                                      value: true,
                                      child: Row(
                                        children: [
                                          Icon(Icons.public_rounded, color: Color(0xFF0052FF), size: 20),
                                          SizedBox(width: 8),
                                          Text('Publish (Active)', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: false,
                                      child: Row(
                                        children: [
                                          Icon(Icons.public_off_rounded, color: Color(0xFFD97706), size: 20),
                                          SizedBox(width: 8),
                                          Text('Unpublish (Inactive)', style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                                if (value != null && mounted) {
                                  final targetUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                                  await PublishUnpublishService.instance.setPublishStatus(
                                    uid: targetUid,
                                    published: value,
                                  );
                                  if (mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          value ? "Enterprise card is now Active & Published!" : "Enterprise card is now Inactive & Unpublished!",
                                        ),
                                        backgroundColor: value ? const Color(0xFF0052FF) : const Color(0xFFD97706),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                isPublished ? Icons.public_rounded : Icons.public_off_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: Text(
                                isPublished ? "Published (Active)" : "Unpublished (Inactive)",
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFF0052FF), width: 1.5),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: false).push(
                                  MaterialPageRoute(
                                    builder: (_) => EnterpriseScannedCardScreen(
                                      cardSlug: slug,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_rounded,
                                  color: Color(0xFF0052FF), size: 18),
                              label: const Text(
                                "View Card",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0052FF),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Basic Info Section ───────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Basic Info",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push('/enterprise/brand-profile'),
                          icon: const Icon(Icons.edit_rounded, size: 15, color: Color(0xFF0052FF)),
                          label: const Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCard(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _isBasicInfoExpanded = !_isBasicInfoExpanded;
                          }),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildRow(Icons.business_rounded,
                                    "Company Name", companyName),
                              ),
                              _buildExpandBtn(_isBasicInfoExpanded),
                            ],
                          ),
                        ),
                        if (_isBasicInfoExpanded) ...[
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(Icons.category_rounded, "Industry", industry),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(Icons.people_alt_rounded, "Employee Count",
                              "$employeeCount Active Member(s)"),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(Icons.workspace_premium_rounded, "Plan Level",
                              "${plan[0].toUpperCase()}${plan.substring(1)} Workspace"),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(Icons.notes_rounded, "Description", bio,
                              isMultiLine: true),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Contact Details Section ──────────────────────────────────────
                    const Text(
                      "Contact & Address Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCard(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _isContactDetailsExpanded = !_isContactDetailsExpanded;
                          }),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildRow(Icons.mail_outline_rounded,
                                    "Work Email", email.isEmpty ? "Not provided" : email),
                              ),
                              _buildExpandBtn(_isContactDetailsExpanded),
                            ],
                          ),
                        ),
                        if (_isContactDetailsExpanded) ...[
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(
                              Icons.phone_rounded,
                              "Phone Number",
                              phone.isEmpty ? "Not provided" : phone),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(
                              Icons.language_rounded,
                              "Website",
                              website.isEmpty ? "Not provided" : website),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          _buildRow(
                              Icons.location_on_rounded,
                              "Address",
                              address.isEmpty ? "Not provided" : address),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Social Media & Online Presence Section ────────────────────────
                    const Text(
                      "Social Media & Presence",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCard(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _isSocialExpanded = !_isSocialExpanded;
                          }),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Company Profiles & Links",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              _buildExpandBtn(_isSocialExpanded),
                            ],
                          ),
                        ),
                        if (_isSocialExpanded) ...[
                          const Divider(color: Color(0xFFF1F5F9), height: 20),
                          _buildSocialMediaBadges(uid, context),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Team Members Overview (after Social section) ───
                    const Text(
                      "Team Members",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const EnterpriseTeamOverviewWidget(),

                    const SizedBox(height: 24),

                    // ── Workspace Invite Link Section ────────────────
                    const EnterpriseInviteLinkWidget(),

                    const SizedBox(height: 24),

                    // ── Brand Card Slug & Link Section ────────────────
                    const EnterpriseBrandSlugWidget(),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }



  Widget _buildSocialMediaBadges(String uid, BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: uid.isNotEmpty
          ? FirebaseFirestore.instance.collection('enterprises').doc(uid).snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final rawMap = data?['socialLinks'] as Map<String, dynamic>? ??
            data?['socials'] as Map<String, dynamic>? ??
            {};
        final socialMap = rawMap.map((k, v) => MapEntry(k.toString(), v.toString()));

        if (socialMap.isEmpty) {
          return GestureDetector(
            onTap: () => context.push('/enterprise/brand-profile'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      color: Color(0xFF0052FF), size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Add Official Enterprise Social Profiles",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: socialMap.entries.map((entry) {
            final key = entry.key.toLowerCase();
            final url = entry.value;

            dynamic icon = FontAwesomeIcons.globe;
            Color color = const Color(0xFF0052FF);

            if (key.contains('linkedin')) {
              icon = FontAwesomeIcons.linkedin;
              color = const Color(0xFF0A66C2);
            } else if (key.contains('twitter') || key.contains('x')) {
              icon = FontAwesomeIcons.xTwitter;
              color = const Color(0xFF0F172A);
            } else if (key.contains('instagram')) {
              icon = FontAwesomeIcons.instagram;
              color = const Color(0xFFE4405F);
            } else if (key.contains('facebook')) {
              icon = FontAwesomeIcons.facebook;
              color = const Color(0xFF1877F2);
            } else if (key.contains('youtube')) {
              icon = FontAwesomeIcons.youtube;
              color = const Color(0xFFFF0000);
            } else if (key.contains('github')) {
              icon = FontAwesomeIcons.github;
              color = const Color(0xFF24292E);
            }

            return ActionChip(
              avatar: FaIcon(icon, color: Colors.white, size: 14),
              label: Text(
                key[0].toUpperCase() + key.substring(1),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onPressed: () => _launchUrl(url),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildExpandBtn(bool isExpanded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isExpanded ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isExpanded ? "Collapse" : "Expand",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isExpanded
                  ? const Color(0xFF0052FF)
                  : const Color(0xFF64748B),
            ),
          ),
          Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 16,
            color: isExpanded
                ? const Color(0xFF0052FF)
                : const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value,
      {bool isMultiLine = false}) {
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
                  color: const Color(0xFF0F172A),
                  height: isMultiLine ? 1.4 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
