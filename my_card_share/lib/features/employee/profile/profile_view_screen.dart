import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/individual/multiple_store/individual_multi_store.dart';
import '../../../backend/individual/previews/publish_unpublish.dart';
import 'profile_editor_screen.dart';
import 'widgets/profile_live_card_preview.dart';
import 'widgets/profile_social_links.dart';
import '../../public_card/public_card_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  bool _isBasicInfoExpanded = false;
  bool _isContactDetailsExpanded = false;
  final GlobalKey _publishBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      PublishUnpublishService.instance.loadPublishStatus(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        IndividualProfileStore.instance,
        PublishUnpublishService.instance,
      ]),
      builder: (context, _) {
        final activeProfile = IndividualProfileStore.instance.activeProfile;
        final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
        final isPublished = PublishUnpublishService.instance.isPublished;

        final name = activeProfile?.fullName ?? storedUser?.fullName ?? "User";
        final role = activeProfile?.jobTitle.isNotEmpty == true ? activeProfile!.jobTitle : "Not specified";
        final company = activeProfile?.companyName.isNotEmpty == true ? activeProfile!.companyName : "Not specified";
        final bio = activeProfile?.shortBio.isNotEmpty == true
            ? activeProfile!.shortBio
            : "No bio added yet.";
        final status = activeProfile?.networkingStatus.isNotEmpty == true ? activeProfile!.networkingStatus : "ACTIVELY NETWORKING";
        final phone = activeProfile?.phoneNumber.isNotEmpty == true ? activeProfile!.phoneNumber : "";
        final email = activeProfile?.email ?? storedUser?.email ?? "";
        final website = activeProfile?.websiteUrl ?? "";
        final slug = activeProfile?.cardSlug ?? IndividualProfileStore.generateCardSlug(name);
        final templateIndex = IndividualProfileStore.getTemplateIndex(activeProfile?.templateStyle);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Profile Card Preview
                  ProfileLiveCardPreview(
                    name: name,
                    role: role,
                    company: company,
                    status: status,
                    selectedTemplateIndex: templateIndex,
                    profilePhoto: activeProfile?.profilePhoto,
                    bannerPhoto: activeProfile?.bannerPhoto,
                    isPublished: isPublished,
                  ),
              const SizedBox(height: 20),
              
              // Action Buttons Row (Image 1 Style: Publish & View Card)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x350052FF),
                            blurRadius: 12,
                            offset: Offset(0, 4),
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
                                    Text('Publish', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: false,
                                child: Row(
                                  children: [
                                    Icon(Icons.public_off_rounded, color: Colors.grey, size: 20),
                                    SizedBox(width: 8),
                                    Text('Unpublish', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          );
                          
                          if (value != null && mounted) {
                            final targetUid = activeProfile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
                            await PublishUnpublishService.instance.setPublishStatus(
                              uid: targetUid,
                              published: value,
                            );
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value ? "Card published successfully!" : "Card unpublished successfully!",
                                  ),
                                  backgroundColor: value ? const Color(0xFF0052FF) : const Color(0xFF475569),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                        icon: Icon(
                          isPublished ? Icons.language_rounded : Icons.public_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          isPublished ? "Publish" : "Unpublished",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x350284C7),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: false).push(
                            MaterialPageRoute(
                              builder: (_) => const PublicCardScreen(showBottomNav: false),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          "View Card",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Basic Info Section Header
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x10000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.edit_rounded, color: Color(0xFF0052FF), size: 20),
                      onPressed: () async {
                        await Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const ProfileEditorScreen()),
                        );
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildViewCard(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBasicInfoExpanded = !_isBasicInfoExpanded;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildViewRow(Icons.person_rounded, "Full Name", name),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallExpandButton(
                          isExpanded: _isBasicInfoExpanded,
                          onTap: () {
                            setState(() {
                              _isBasicInfoExpanded = !_isBasicInfoExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Column(
                      children: [
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        _buildViewRow(Icons.work_rounded, "Job Title", role),
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        _buildViewRow(Icons.business_rounded, "Company", company),
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        _buildViewRow(Icons.edit_note_rounded, "Bio", bio, isMultiLine: true),
                      ],
                    ),
                    crossFadeState: _isBasicInfoExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 280),
                    sizeCurve: Curves.fastOutSlowIn,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Contact Details Section Header
              const Text(
                "Contact Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildViewCard(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isContactDetailsExpanded = !_isContactDetailsExpanded;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildViewRow(Icons.phone_rounded, "Phone", phone.isEmpty ? "Not provided" : phone),
                        ),
                        const SizedBox(width: 8),
                        _buildSmallExpandButton(
                          isExpanded: _isContactDetailsExpanded,
                          onTap: () {
                            setState(() {
                              _isContactDetailsExpanded = !_isContactDetailsExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Column(
                      children: [
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        _buildViewRow(Icons.email_rounded, "Email", email.isEmpty ? "Not provided" : email),
                        const Divider(color: Color(0xFFF1F5F9), height: 24),
                        _buildViewRow(Icons.language_rounded, "Website", website.isEmpty ? "Not provided" : website),
                      ],
                    ),
                    crossFadeState: _isContactDetailsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 280),
                    sizeCurve: Curves.fastOutSlowIn,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Social Links Section
              ProfileSocialLinks(
                links: activeProfile?.socialLinks,
                onManageTap: () async {
                  await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const ProfileEditorScreen()),
                  );
                  setState(() {});
                },
                onAddMoreTap: () async {
                  await Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const ProfileEditorScreen()),
                  );
                  setState(() {});
                },
              ),
              
              const SizedBox(height: 24),
              
              // Card Link Section (Slug Display)
              const Text(
                "Card Link",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              _buildViewCard(
                children: [
                  _buildViewRow(Icons.link_rounded, "Slug", slug),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildViewCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
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
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isExpanded ? "Collapse" : "Expand",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isExpanded ? const Color(0xFF0052FF) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: isExpanded ? const Color(0xFF0052FF) : const Color(0xFF64748B),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0052FF)),
        const SizedBox(width: 16),
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
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                  height: isMultiLine ? 1.45 : 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


