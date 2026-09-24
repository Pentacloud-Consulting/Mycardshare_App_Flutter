import 'package:flutter/material.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/individual/multiple store/individual_multi_store.dart';
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
  bool _isPublished = true;
  bool _isBasicInfoExpanded = false;
  bool _isContactDetailsExpanded = false;
  final GlobalKey _publishBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: IndividualProfileStore.instance,
      builder: (context, _) {
        final activeProfile = IndividualProfileStore.instance.activeProfile;
        final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;

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
                    isPublished: _isPublished,
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
                          final RenderBox button = _publishBtnKey.currentContext!.findRenderObject() as RenderBox;
                          final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
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
                            setState(() {
                              _isPublished = value;
                            });
                          }
                        },
                        icon: Icon(
                          _isPublished ? Icons.language_rounded : Icons.public_off_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          _isPublished ? "Publish" : "Unpublished",
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

              // Basic Info Section Header with Expand Button & Edit Pencil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBasicInfoExpanded = !_isBasicInfoExpanded;
                      });
                    },
                    child: Row(
                      children: const [
                        Text(
                          "Basic Info",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Expand / Collapse Pill Button on Right Side
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isBasicInfoExpanded = !_isBasicInfoExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isBasicInfoExpanded ? "Collapse" : "Expand",
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0052FF),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _isBasicInfoExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: const Color(0xFF0052FF),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _buildViewCard(
                  children: [
                    _buildViewRow(Icons.person_rounded, "Full Name", name),
                    if (_isBasicInfoExpanded) ...[
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildViewRow(Icons.work_rounded, "Job Title", role),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildViewRow(Icons.business_rounded, "Company", company),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildViewRow(Icons.edit_note_rounded, "Bio", bio, isMultiLine: true),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Details Section Header with Expand Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isContactDetailsExpanded = !_isContactDetailsExpanded;
                      });
                    },
                    child: const Text(
                      "Contact Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isContactDetailsExpanded = !_isContactDetailsExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isContactDetailsExpanded ? "Collapse" : "Expand",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isContactDetailsExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF0052FF),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _buildViewCard(
                  children: [
                    _buildViewRow(Icons.phone_rounded, "Phone", phone.isEmpty ? "Not provided" : phone),
                    if (_isContactDetailsExpanded) ...[
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildViewRow(Icons.email_rounded, "Email", email.isEmpty ? "Not provided" : email),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildViewRow(Icons.language_rounded, "Website", website.isEmpty ? "Not provided" : website),
                    ],
                  ],
                ),
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
