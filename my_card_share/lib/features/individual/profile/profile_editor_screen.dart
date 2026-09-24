import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';
import '../../../backend/individual/multiple store/individual_multi_store.dart';
import 'widgets/profile_basic_info.dart';
import 'widgets/profile_contact_details.dart';
import 'widgets/profile_live_card_preview.dart';
import 'widgets/profile_slug_section.dart';
import 'widgets/profile_social_links.dart';
import 'widgets/profile_template_selector.dart';

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  int _selectedTemplateIndex = 0;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _companyController;
  late TextEditingController _bioController;

  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;

  late TextEditingController _slugController;

  late List<SocialLinkItem> _socialLinks;
  late String _uid;
  String? _bannerImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final active = IndividualProfileStore.instance.activeProfile;
    final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;

    _uid = active?.uid ?? storedUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    _selectedTemplateIndex = IndividualProfileStore.getTemplateIndex(active?.templateStyle);
    _bannerImagePath = active?.bannerPhoto;

    _nameController = TextEditingController(text: active?.fullName ?? storedUser?.fullName ?? "");
    _roleController = TextEditingController(text: active?.jobTitle ?? "");
    _companyController = TextEditingController(text: active?.companyName ?? "");
    _bioController = TextEditingController(
      text: active?.shortBio ?? "",
    );

    _phoneController = TextEditingController(text: active?.phoneNumber ?? "");
    _emailController = TextEditingController(text: active?.email ?? storedUser?.email ?? "");
    _websiteController = TextEditingController(text: active?.websiteUrl ?? "");

    _slugController = TextEditingController(
      text: active?.cardSlug ?? IndividualProfileStore.generateCardSlug(_nameController.text),
    );

    if (active?.socialLinks != null && active!.socialLinks.isNotEmpty) {
      _socialLinks = active.socialLinks.map((l) => SocialLinkItem(platform: l.platform, url: l.url)).toList();
    } else {
      _socialLinks = [
        SocialLinkItem(platform: 'LinkedIn', url: ''),
        SocialLinkItem(platform: 'Instagram', url: ''),
      ];
    }

    _nameController.addListener(() => setState(() {}));
    _roleController.addListener(() => setState(() {}));
    _companyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _bannerImagePath = pickedFile.path;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Banner image selected! Tap checkmark to save.')),
        );
      }
    } catch (e) {
      debugPrint('Error picking banner: $e');
    }
  }

  void _showManageSocialLinksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Manage Social Links",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0052FF))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_socialLinks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text("No links added yet. Tap below to add one!"),
                        ),
                      ),
                    ..._socialLinks.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: item.platform,
                                dropdownColor: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0052FF)),
                                items: [
                                  'LinkedIn',
                                  'Instagram',
                                  'WhatsApp',
                                  'GitHub',
                                  'Twitter / X',
                                  'YouTube',
                                ].map((p) {
                                  return DropdownMenuItem<String>(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setSheetState(() => item.platform = val);
                                    setState(() {});
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: item.url)
                                  ..selection = TextSelection.collapsed(offset: item.url.length),
                                onChanged: (val) {
                                  item.url = val;
                                  setState(() {});
                                },
                                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                                decoration: const InputDecoration(
                                  hintText: 'handle or URL...',
                                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              onPressed: () {
                                setSheetState(() => _socialLinks.removeAt(idx));
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        setSheetState(() {
                          _socialLinks.add(SocialLinkItem(platform: 'LinkedIn', url: ''));
                        });
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF0052FF)),
                      label: const Text(
                        'Add Another Link',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    await IndividualProfileStore.instance.saveProfile(
      uid: _uid,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      customSlug: _slugController.text.trim(),
      bannerPhoto: _bannerImagePath,
      jobTitle: _roleController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      websiteUrl: _websiteController.text.trim(),
      templateStyle: _selectedTemplateIndex.toString(),
      socialLinks: _socialLinks,
      companyName: _companyController.text.trim(),
      shortBio: _bioController.text.trim(),
      networkingStatus: 'Actively Networking',
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFD),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Back button + title
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF334155),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'LIVE PREVIEW',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Right: Save Checkmark Button
                IconButton(
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded, color: Color(0xFF0052FF), size: 28),
                  onPressed: _isSaving ? null : _saveChanges,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Card Preview Banner
              ProfileLiveCardPreview(
                name: _nameController.text.isEmpty ? "Your Name" : _nameController.text,
                role: _roleController.text.isEmpty ? "Your Role" : _roleController.text,
                company: _companyController.text.isEmpty ? "Your Company" : _companyController.text,
                status: "Actively Networking",
                selectedTemplateIndex: _selectedTemplateIndex,
                bannerPhoto: _bannerImagePath,
              ),

              const SizedBox(height: 16),

              // Upload Banner Image Action Button
              GestureDetector(
                onTap: _pickBannerImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF0052FF), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Upload Custom Banner Image",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0052FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Template Color Selector (Image 4)
              ProfileTemplateSelector(
                selectedIndex: _selectedTemplateIndex,
                onSelectTemplate: (index) {
                  setState(() {
                    _selectedTemplateIndex = index;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Basic Info Inputs
              ProfileBasicInfo(
                nameController: _nameController,
                roleController: _roleController,
                companyController: _companyController,
                bioController: _bioController,
              ),

              const SizedBox(height: 20),

              // Contact Details Inputs
              ProfileContactDetails(
                phoneController: _phoneController,
                emailController: _emailController,
                websiteController: _websiteController,
              ),

              const SizedBox(height: 20),

              // Social Links Section
              ProfileSocialLinks(
                links: _socialLinks,
                isEditable: true,
                onManageTap: _showManageSocialLinksSheet,
                onAddMoreTap: _showManageSocialLinksSheet,
                onDeleteItem: (idx) {
                  setState(() {
                    _socialLinks.removeAt(idx);
                  });
                },
              ),

              const SizedBox(height: 20),

              // Card Slug Section (Image 5)
              ProfileSlugSection(
                slugController: _slugController,
              ),

              const SizedBox(height: 30),

              // Bottom Save Changes Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Container(
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
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

