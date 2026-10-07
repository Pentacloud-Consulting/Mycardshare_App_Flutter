import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_logo_picker.dart';
import 'brand_banner_picker.dart';
import 'brand_color_selector.dart';
import 'brand_template_selector.dart';
import 'brand_live_preview.dart';
import 'brand_social.dart';
import 'brand_save_popup.dart';
import 'brand_save_button.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';
import '../../../../backend/enterprise/invite_employee/invite_link.dart';

/// Real Enterprise Brand & Workspace Details Widget.
class EnterpriseBrandDetailWidget extends StatefulWidget {
  const EnterpriseBrandDetailWidget({super.key});

  @override
  State<EnterpriseBrandDetailWidget> createState() => _EnterpriseBrandDetailWidgetState();
}

class _EnterpriseBrandDetailWidgetState extends State<EnterpriseBrandDetailWidget> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  Color _selectedColor = const Color(0xFF0052FF);
  bool _isLocked = true;
  String _selectedTemplateId = 'modern_glass';
  bool _isSaving = false;
  Map<String, String> _socialMap = {};

  // Collapsible Dropdown States
  bool _isBrandColorExpanded = true;
  bool _isTemplateExpanded = false;
  bool _isBasicInfoExpanded = true;
  bool _isContactDetailsExpanded = false;
  bool _isSocialExpanded = false;

  @override
  void initState() {
    super.initState();
    _companyNameController.addListener(_onNameChanged);
    _loadProfileData();
  }

  void _onNameChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await EnterpriseProfileStore.instance.loadProfile(uid, '', '');
    final profile = EnterpriseProfileStore.instance.currentProfile;

    if (profile != null && mounted) {
      setState(() {
        _companyNameController.text = profile.companyName;
        _industryController.text = profile.industry;
        _websiteController.text = profile.website;
        _phoneController.text = profile.phoneNumber;
        _addressController.text = profile.address;
        _bioController.text = profile.shortBio;
        _selectedTemplateId = profile.templateId;
        try {
          final colorHex = profile.brandColor.replaceFirst('#', 'FF');
          _selectedColor = Color(int.parse('0x$colorHex'));
        } catch (_) {}
      });
    }

    final doc = await FirebaseFirestore.instance.collection('enterprises').doc(uid).get();
    if (doc.exists && doc.data() != null && mounted) {
      final data = doc.data()!;
      final rawMap = data['socialLinks'] as Map<String, dynamic>? ??
          data['socials'] as Map<String, dynamic>? ??
          {};
      setState(() {
        _socialMap = rawMap.map((k, v) => MapEntry(k.toString(), v.toString()));
        if (_companyNameController.text.isEmpty) {
          _companyNameController.text = data['companyName'] ?? '';
          _industryController.text = data['industry'] ?? '';
          _websiteController.text = data['website'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _bioController.text = data['shortBio'] ?? data['bio'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _companyNameController.removeListener(_onNameChanged);
    _companyNameController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveAllDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (uid == null) return;

    setState(() => _isSaving = true);

    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    final success = await EnterpriseProfileStore.instance.saveProfile(
      uid: uid,
      companyName: _companyNameController.text.trim(),
      email: email,
      industry: _industryController.text.trim(),
      website: _websiteController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      shortBio: _bioController.text.trim(),
      brandColor: colorHex,
      templateId: _selectedTemplateId,
    );

    // Also persist socialLinks map to Firestore
    if (success) {
      await FirebaseFirestore.instance.collection('enterprises').doc(uid).set({
        'socialLinks': _socialMap,
        'socials': _socialMap,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    setState(() => _isSaving = false);

    if (!mounted) return;
    if (success) {
      BrandSavePopup.show(
        context,
        title: "Profile Updated!",
        message: "Your enterprise brand profile, workspace styling, and social links have been updated successfully.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Top Section: Real-time Live Preview (Image 1 - directly above logo & banner) ──
        BrandLivePreview(
          selectedColor: _selectedColor,
          selectedTemplateId: _selectedTemplateId,
          companyName: _companyNameController.text,
        ),

        const SizedBox(height: 24),

        // ── 2. Company Logo & Cover Banner Upload Pickers (Image 2) ────────────
        const BrandLogoPicker(),

        const SizedBox(height: 24),

        const BrandBannerPicker(showLockToggle: false),

        const SizedBox(height: 24),

        // ── 3. Expandable Dropdown: Brand Color Palette & Single Lock Switch ──
        _buildExpandableSection(
          title: "Brand Color & Organization Lock",
          subtitle: "Official color palette and employee brand enforcement",
          isExpanded: _isBrandColorExpanded,
          onToggle: () => setState(() => _isBrandColorExpanded = !_isBrandColorExpanded),
          child: BrandColorSelector(
            selectedColor: _selectedColor,
            onColorSelected: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            isLocked: _isLocked,
            onLockChanged: (val) {
              setState(() {
                _isLocked = val;
              });
            },
          ),
        ),

        const SizedBox(height: 20),

        // ── 4. Expandable Dropdown: Default Card Template Style ───────────
        _buildExpandableSection(
          title: "Default Card Template",
          subtitle: "Selected style: ${_selectedTemplateId.replaceAll('_', ' ').toUpperCase()}",
          isExpanded: _isTemplateExpanded,
          onToggle: () => setState(() => _isTemplateExpanded = !_isTemplateExpanded),
          child: BrandTemplateSelector(
            selectedTemplateId: _selectedTemplateId,
            onTemplateSelected: (id) {
              setState(() {
                _selectedTemplateId = id;
              });
            },
          ),
        ),

        const SizedBox(height: 20),

        // ── 5. Expandable Dropdown: Company Basic Info ──
        _buildExpandableSection(
          title: "Basic Info",
          subtitle: "Company Name, Industry Sector & Overview",
          isExpanded: _isBasicInfoExpanded,
          onToggle: () => setState(() => _isBasicInfoExpanded = !_isBasicInfoExpanded),
          child: Column(
            children: [
              _buildInputField(
                controller: _companyNameController,
                label: "Company Name",
                hint: "Enter official company name",
                icon: Icons.domain_rounded,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _industryController,
                label: "Industry Sector",
                hint: "e.g. Technology, Finance, Healthcare",
                icon: Icons.category_rounded,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _bioController,
                label: "Company Overview / Bio",
                hint: "Short summary of your enterprise organization...",
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── 6. Expandable Dropdown: Contact & Location Details (Image 4) ──
        _buildExpandableSection(
          title: "Contact & Location Details",
          subtitle: "Website, Business Phone & Physical Address",
          isExpanded: _isContactDetailsExpanded,
          onToggle: () => setState(() => _isContactDetailsExpanded = !_isContactDetailsExpanded),
          child: Column(
            children: [
              _buildInputField(
                controller: _websiteController,
                label: "Website URL",
                hint: "https://company.com",
                icon: Icons.language_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _phoneController,
                label: "Business Phone Number",
                hint: "+1 (555) 000-0000",
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _addressController,
                label: "Office Address",
                hint: "123 Corporate Way, Suite 200",
                icon: Icons.location_on_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── 7. Expandable Dropdown: Social Platforms & Links (Added after Image 4) ──
        _buildExpandableSection(
          title: "Social Platforms & Links",
          subtitle: "LinkedIn, X/Twitter, Instagram, YouTube, GitHub & Facebook",
          isExpanded: _isSocialExpanded,
          onToggle: () => setState(() => _isSocialExpanded = !_isSocialExpanded),
          child: BrandSocialWidget(
            initialLinks: _socialMap,
            onChanged: (map) {
              _socialMap = map;
            },
          ),
        ),

        const SizedBox(height: 24),

        // ── 8. Workspace & Employee Invite Link Card ───────────────────────────
        const EnterpriseInviteLinkWidget(),

        const SizedBox(height: 28),

        // ── 9. Save Changes Button ──────────────────────────────────────────────
        BrandSaveButton(
          onPressed: _isSaving ? null : _saveAllDetails,
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isExpanded ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isExpanded ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        isExpanded ? "Collapse" : "Expand",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isExpanded ? const Color(0xFF0052FF) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: isExpanded ? const Color(0xFF0052FF) : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Color(0xFFF1F5F9), height: 24),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}


