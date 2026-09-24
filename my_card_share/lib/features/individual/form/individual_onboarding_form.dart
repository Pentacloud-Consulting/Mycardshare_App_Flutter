import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_card_share/core/theme/app_theme.dart';
import 'package:my_card_share/backend/individual/profile/individual_profile_store.dart';
import 'package:my_card_share/backend/individual/multiple store/individual_multi_store.dart';

class IndividualOnboardingFormScreen extends StatefulWidget {
  final String? initialFullName;
  final String? initialEmail;
  final String? uid;

  const IndividualOnboardingFormScreen({
    super.key,
    this.initialFullName,
    this.initialEmail,
    this.uid,
  });

  @override
  State<IndividualOnboardingFormScreen> createState() =>
      _IndividualOnboardingFormScreenState();
}

class _IndividualOnboardingFormScreenState
    extends State<IndividualOnboardingFormScreen> {
  int _currentStep = 1;
  bool _isLoading = false;
  int _selectedColorIndex = 0;

  // Auto-filled System Info
  late String _fullName;
  late String _email;
  late String _uid;

  // Step 1 & 2 Controllers & Real Image Upload State
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Real Profile Image Upload bytes / path
  Uint8List? _profileImageBytes;
  String? _profileImagePath;
  Uint8List? _bannerImageBytes;
  String? _bannerImagePath;
  final ImagePicker _picker = ImagePicker();

  // Step 2 Social Links State
  final List<SocialLinkItem> _socialLinks = [
    SocialLinkItem(platform: 'LinkedIn', url: ''),
    SocialLinkItem(platform: 'Instagram', url: ''),
  ];

  // Step 3 Controllers & Card Slug State (Image 5)
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  String _networkingStatus = 'Actively Networking';

  // Template Theme Color Swatches (Image 4)
  final List<List<Color>> _colorSwatches = [
    [const Color(0xFF0052FF), const Color(0xFF38BDF8)],
    [const Color(0xFF833AB4), const Color(0xFFC13584)],
    [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
    [const Color(0xFF0F172A), const Color(0xFF334155)],
    [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
  ];

  // Preset 10 Networking Status Options
  final List<String> _networkingStatusOptions = [
    'Actively Networking',
    'Open to Opportunities',
    'Hiring / Looking for Talent',
    'Exploring Partnerships',
    'Speaker / Mentor',
    'Freelancing / Available for Hire',
    'Investing / Angel Investor',
    'Founder / Co-Founder',
    'Learning / Student',
    'Not Looking',
  ];

  // Available Social Platforms (Website is in its own dedicated section)
  final List<String> _platforms = [
    'LinkedIn',
    'Instagram',
    'WhatsApp',
    'GitHub',
    'Twitter / X',
    'YouTube',
  ];

  @override
  void initState() {
    super.initState();
    final storedUser = IndividualMultiStore.instance.getAllUsers().firstOrNull;
    _fullName = widget.initialFullName ?? storedUser?.fullName ?? 'Alex Stanton';
    _email = widget.initialEmail ?? storedUser?.email ?? 'alex.stanton@example.com';
    _uid = widget.uid ?? storedUser?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Load active profile data if available
    final active = IndividualProfileStore.instance.activeProfile;
    if (active != null) {
      _jobTitleController.text = active.jobTitle;
      _phoneController.text = active.phoneNumber;
      _websiteController.text = active.websiteUrl;
      _selectedColorIndex = IndividualProfileStore.getTemplateIndex(active.templateStyle);
      _companyController.text = active.companyName;
      _bioController.text = active.shortBio;
      _networkingStatus = active.networkingStatus;
      _slugController.text = active.cardSlug;
      if (active.socialLinks.isNotEmpty) {
        _socialLinks.clear();
        _socialLinks.addAll(active.socialLinks.where((l) => l.platform != 'Website' && l.platform != 'Portfolio'));
        if (_socialLinks.isEmpty) {
          _socialLinks.add(SocialLinkItem(platform: 'LinkedIn', url: ''));
        }
      }
    } else {
      _slugController.text = IndividualProfileStore.generateCardSlug(_fullName);
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  // Real Profile Image Upload Picker Dialog
  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Wrap(
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
                const Center(
                  child: Text(
                    'Upload Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0052FF)),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _getImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0052FF)),
                  ),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _getImage(ImageSource.camera);
                  },
                ),
                if (_profileImageBytes != null || _profileImagePath != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    ),
                    title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _profileImageBytes = null;
                        _profileImagePath = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
          _profileImagePath = pickedFile.path;
        });
        _showSnackBar('Photo uploaded successfully!');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showSnackBar('Could not pick image. Please try again.');
    }
  }

  Future<void> _pickBannerImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Wrap(
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
                const Center(
                  child: Text(
                    'Upload Custom Banner Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF0052FF)),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _getBannerImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0052FF)),
                  ),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _getBannerImage(ImageSource.camera);
                  },
                ),
                if (_bannerImageBytes != null || _bannerImagePath != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    ),
                    title: const Text('Remove Banner', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _bannerImageBytes = null;
                        _bannerImagePath = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getBannerImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _bannerImageBytes = bytes;
          _bannerImagePath = pickedFile.path;
        });
        _showSnackBar('Banner uploaded successfully!');
      }
    } catch (e) {
      debugPrint('Error picking banner image: $e');
      _showSnackBar('Could not pick banner image.');
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_jobTitleController.text.trim().isEmpty) {
        _showSnackBar('Please enter your Job Title');
        return;
      }
      if (_phoneController.text.trim().isEmpty) {
        _showSnackBar('Please enter your Phone Number');
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);

    final validLinks = _socialLinks
        .where((link) => link.url.trim().isNotEmpty)
        .toList();

    final userSlug = _slugController.text.trim().isNotEmpty
        ? _slugController.text.trim()
        : IndividualProfileStore.generateCardSlug(_fullName);

    await IndividualProfileStore.instance.saveProfile(
      uid: _uid,
      fullName: _fullName,
      email: _email,
      customSlug: userSlug,
      profilePhoto: _profileImagePath,
      bannerPhoto: _bannerImagePath,
      jobTitle: _jobTitleController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      websiteUrl: _websiteController.text.trim(),
      templateStyle: _selectedColorIndex.toString(),
      socialLinks: validLinks,
      companyName: _companyController.text.trim(),
      shortBio: _bioController.text.trim(),
      networkingStatus: _networkingStatus,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      _showSnackBar('Profile created successfully!');
      context.go('/portal');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Set Up Your Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Auto-Filled Header Banner
              _buildAutoFilledBanner(),

              const SizedBox(height: 20),

              // Stepper Progress Bar
              _buildStepperHeader(),

              const SizedBox(height: 24),

              // Active Step Form Container
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepContent(),
              ),

              const SizedBox(height: 36),

              // Image 1 Style Double Pill Action Buttons ("Publish / View Card" or "Back / Next Step")
              _buildImage1ActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // Image 1 Styled Double Pill Action Buttons (Interactive & Premium)
  Widget _buildImage1ActionButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            flex: 1,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _previousStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFF334155)),
                label: const Text(
                  'Back',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                ),
              ),
            ),
          ),
        if (_currentStep > 1) const SizedBox(width: 12),
        Expanded(
          flex: 2,
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
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentStep == 3 ? Icons.public_rounded : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentStep == 3 ? 'Publish Profile' : 'Next Step',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // System Auto-Filled Banner Display
  Widget _buildAutoFilledBanner() {
    final slugDisplay = _slugController.text.isNotEmpty
        ? _slugController.text
        : IndividualProfileStore.generateCardSlug(_fullName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF0052FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$_email  •  mycardshare.com/card/$slugDisplay',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Stepper Header Bar
  Widget _buildStepperHeader() {
    return Row(
      children: [
        _buildStepItem(1, 'Profile', _currentStep >= 1),
        _buildStepDivider(_currentStep >= 2),
        _buildStepItem(2, 'Links', _currentStep >= 2),
        _buildStepDivider(_currentStep >= 3),
        _buildStepItem(3, 'Status & Slug', _currentStep >= 3),
      ],
    );
  }

  Widget _buildStepItem(int stepNum, String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                '$stepNum',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: isActive ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Profile();
      case 2:
        return _buildStep2Links();
      case 3:
        return _buildStep3DetailsAndSlug();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── STEP 1: SET UP YOUR PROFILE (With Color Swatch Selector as Image 4) ────
  Widget _buildStep1Profile() {
    return Container(
      key: const ValueKey(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 1 — Set Up Your Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload your profile photo, job title, phone number and select template color.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Real Profile Photo Upload Container (No Mock Image)
          Center(
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFF6FF),
                          border: Border.all(color: const Color(0xFF0052FF), width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x180052FF),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _profileImageBytes != null
                              ? Image.memory(
                                  _profileImageBytes!,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0052FF),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x20000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileImageBytes != null ? 'Tap to change photo' : 'Upload Profile Photo',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Upload Banner Image Section
          GestureDetector(
            onTap: _pickBannerImage,
            child: Container(
              width: double.infinity,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _bannerImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(_bannerImageBytes!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF0052FF), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "Upload Banner Image (Optional)",
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

          // Template Color Swatches (As shown in Image 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Template Color *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              Text(
                'See All',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_colorSwatches.length, (index) {
              final isSel = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _colorSwatches[index],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? const Color(0xFF0052FF) : Colors.transparent,
                      width: isSel ? 2.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSel ? const Color(0x350052FF) : const Color(0x0A000000),
                        blurRadius: isSel ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSel
                      ? Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0052FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Job Title (Required)
          _buildTextField(
            controller: _jobTitleController,
            label: 'Job Title *',
            hint: 'e.g. Senior Product Designer',
            icon: Icons.work_outline_rounded,
          ),

          const SizedBox(height: 16),

          // Phone Number (Required)
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number *',
            hint: 'e.g. +91 98765 43210',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ── STEP 2: ADD YOUR LINKS ──────────────────────────────────────────────────
  Widget _buildStep2Links() {
    return Container(
      key: const ValueKey(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 2 — Add Your Links',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add your website URL & social handles for quick sharing.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Dedicated Website Link Section (Separate from Social Links)
          _buildTextField(
            controller: _websiteController,
            label: 'Website Link (Optional)',
            hint: 'e.g. https://yourwebsite.com',
            icon: Icons.language_rounded,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 20),

          const Text(
            'Social Handles',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),

          // Dynamic Links List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _socialLinks.length,
            itemBuilder: (context, index) {
              final link = _socialLinks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // CSS Styled Platform Dropdown Menu
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: link.platform,
                          dropdownColor: Colors.white,
                          elevation: 8,
                          menuMaxHeight: 300,
                          borderRadius: BorderRadius.circular(16),
                          icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF0052FF)),
                          items: _platforms.map((p) {
                            final isSel = link.platform == p;
                            return DropdownMenuItem<String>(
                              value: p,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFFEFF6FF) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                    color: isSel ? const Color(0xFF0052FF) : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => link.platform = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // URL / Handle Input
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: link.url)
                          ..selection = TextSelection.collapsed(offset: link.url.length),
                        onChanged: (val) => link.url = val,
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: 'handle or URL...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                        ),
                      ),
                    ),

                    if (_socialLinks.length > 1) const SizedBox(width: 4),

                    // Remove Button
                    if (_socialLinks.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() => _socialLinks.removeAt(index));
                        },
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // Add Link Button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _socialLinks.add(SocialLinkItem(platform: 'LinkedIn', url: ''));
              });
            },
            icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF0052FF)),
            label: const Text(
              'Add Another Link',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0052FF)),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              side: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 3: ALMOST THERE! (With Card Slug & Styled Dropdown as Image 4 & 5) ──
  Widget _buildStep3DetailsAndSlug() {
    return Container(
      key: const ValueKey(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Step 3 — Almost There!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Provide company details, short bio, networking status and your card slug.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),

          // Company Name (Optional)
          _buildTextField(
            controller: _companyController,
            label: 'Company Name (Optional)',
            hint: 'e.g. Acme Realty Group',
            icon: Icons.business_rounded,
          ),

          const SizedBox(height: 16),

          // Short Bio (Optional - Max 200 Chars)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Short Bio (Optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  Text(
                    '${_bioController.text.length}/200',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bioController,
                maxLength: 200,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Passionate about creating meaningful connections...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Networking Status (With Styled Dropdown Box)
          const Text(
            'Networking Status *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _networkingStatus,
                isExpanded: true,
                dropdownColor: Colors.white,
                elevation: 8,
                menuMaxHeight: 320,
                borderRadius: BorderRadius.circular(16),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0052FF), size: 24),
                items: _networkingStatusOptions.map((st) {
                  final isSel = _networkingStatus == st;
                  return DropdownMenuItem<String>(
                    value: st,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFEFF6FF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel ? Icons.check_circle_rounded : Icons.fiber_manual_record_rounded,
                            size: isSel ? 16 : 10,
                            color: isSel ? const Color(0xFF0052FF) : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              st,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                color: isSel ? const Color(0xFF0052FF) : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _networkingStatus = val);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Card Slug Editable Field (As shown in Image 5)
          const Text(
            'Card Link / Slug *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.link_rounded, color: Color(0xFF0052FF), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'mycardshare.com/card/',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _slugController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0052FF),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintText: 'alex-stanton',
                      hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
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

  // Reusable Text Input Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14.5, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF0052FF), size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }
}
