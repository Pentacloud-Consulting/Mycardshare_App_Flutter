import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../backend/enterprise/lock_banner/custom_color_picker.dart';

class EnterpriseOnboardingScreen extends StatefulWidget {
  const EnterpriseOnboardingScreen({super.key});

  @override
  State<EnterpriseOnboardingScreen> createState() => _EnterpriseOnboardingScreenState();
}

class _EnterpriseOnboardingScreenState extends State<EnterpriseOnboardingScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _emailInputController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  int _currentStep = 1;
  int _selectedColorIndex = 0;
  Color? _customColor;
  bool _lockBrandColor = true;
  bool _isLoading = false;

  Uint8List? _logoBytes;
  Uint8List? _bannerBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickLogo() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _logoBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('[Onboarding] Error picking logo: $e');
    }
  }

  Future<void> _pickBanner() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1400,
        maxHeight: 600,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _bannerBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('[Onboarding] Error picking banner: $e');
    }
  }

  String _selectedEmployeeLimit = "Up to 50 employees";

  static const List<String> _employeeLimitOptions = [
    "1 - 10 employees",
    "Up to 50 employees",
    "51 - 200 employees",
    "201 - 500 employees",
    "500+ employees",
  ];

  String get _inviteLink {
    final name = _companyNameController.text.trim();
    final slug = name.isNotEmpty
        ? name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')
        : 'workspace';
    return "mycardshare.com/join-workspace?code=${slug.toUpperCase()}-2026";
  }

  final List<String> _invitedEmails = [];

  final List<Color> _brandColors = const [
    Color(0xFF0052FF), // Primary Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFF0D9488), // Teal
    Color(0xFF0F172A), // Dark Navy
    Color(0xFFF59E0B), // Amber
    Color(0xFFE11D48), // Rose
  ];

  Color get _activeBrandColor =>
      _customColor ?? _brandColors[_selectedColorIndex];

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailInputController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        final companyName = _companyNameController.text.trim();
        final website = _websiteController.text.trim();
        final address = _addressController.text.trim();

        if (user != null) {
          final uid = user.uid;
          String? logoUrl;
          String? bannerUrl;

          if (_logoBytes != null) {
            try {
              final logoRef = FirebaseStorage.instance
                  .ref()
                  .child('enterprise_logos')
                  .child(uid)
                  .child('logo.jpg');
              final task = await logoRef.putData(
                _logoBytes!,
                SettableMetadata(contentType: 'image/jpeg'),
              );
              logoUrl = await task.ref.getDownloadURL();
            } catch (e) {
              debugPrint('[Onboarding] Logo upload error: $e');
            }
          }

          if (_bannerBytes != null) {
            try {
              final bannerRef = FirebaseStorage.instance
                  .ref()
                  .child('enterprise_banners')
                  .child(uid)
                  .child('banner.jpg');
              final task = await bannerRef.putData(
                _bannerBytes!,
                SettableMetadata(contentType: 'image/jpeg'),
              );
              bannerUrl = await task.ref.getDownloadURL();
            } catch (e) {
              debugPrint('[Onboarding] Banner upload error: $e');
            }
          }

          final colorVal = _activeBrandColor.toARGB32();
          await FirebaseFirestore.instance.collection('enterprises').doc(uid).set({
            'companyName': companyName.isNotEmpty ? companyName : 'Enterprise Workspace',
            'website': website,
            'address': address,
            'employeeLimit': _selectedEmployeeLimit,
            'brandColor': colorVal,
            'lockBrandColor': _lockBrandColor,
            'invitedEmails': _invitedEmails,
            'logoUrl': logoUrl,
            'lockedBannerUrl': bannerUrl,
            'bannerLocked': bannerUrl != null ? _lockBrandColor : false,
            'onboardingCompleted': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            if (companyName.isNotEmpty) 'companyName': companyName,
            'logoUrl': logoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('[EnterpriseOnboarding] Error saving onboarding data: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go('/enterprise/dashboard');
      }
    }
  }

  void _handleBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.go('/login');
    }
  }

  void _addEmail() {
    final email = _emailInputController.text.trim();
    if (email.isNotEmpty && email.contains('@')) {
      setState(() {
        if (!_invitedEmails.contains(email)) {
          _invitedEmails.add(email);
        }
        _emailInputController.clear();
      });
    } else if (email.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a valid email address"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _removeEmail(int index) {
    setState(() {
      _invitedEmails.removeAt(index);
    });
  }

  void _copyInviteLink() {
    Clipboard.setData(ClipboardData(text: "https://$_inviteLink"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Invite link copied to clipboard!"),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareInviteLink() {
    Clipboard.setData(ClipboardData(text: "https://$_inviteLink"));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.share_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Workspace invite link copied to share!"),
          ],
        ),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Background Top/Bottom Ambient Baby-Blue Gradient Blob
          Positioned(
            top: _currentStep == 3 ? null : -70,
            bottom: _currentStep == 3 ? -70 : null,
            left: _currentStep == 2 ? -70 : null,
            right: _currentStep == 2 ? null : -70,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.20),
                    const Color(0xFF0052FF).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Progress Bar & Back Nav Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back text link & Step Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _handleBack,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 14,
                                  color: Color(0xFF64748B),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Back",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Step $_currentStep of 3",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 3-Segmented Horizontal Step Progress Bar
                      Row(
                        children: List.generate(3, (index) {
                          final isFilled = index < _currentStep;
                          return Expanded(
                            child: Container(
                              height: 5,
                              margin: EdgeInsets.only(
                                right: index < 2 ? 8.0 : 0.0,
                              ),
                              decoration: BoxDecoration(
                                color: isFilled
                                    ? const Color(0xFF0052FF)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: _currentStep == 1
                        ? _buildStep1()
                        : _currentStep == 2
                            ? _buildStep2()
                            : _buildStep3(),
                  ),
                ),

                // Bottom Gradient Continue Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentStep == 3 ? "Complete Setup ✓" : "Continue",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_currentStep < 3) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
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

  // --- STEP 1: SET UP YOUR COMPANY ---
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline Title
        const Text(
          "Set Up Your Company",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "This branding will apply across your team's cards",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 28),

        // Center Company Logo Upload Box
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _logoBytes != null
                          ? const Color(0xFF0052FF)
                          : const Color(0xFFBFDBFE),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0052FF).withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _logoBytes != null
                        ? Image.memory(
                            _logoBytes!,
                            width: 104,
                            height: 104,
                            fit: BoxFit.cover,
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_rounded,
                                size: 38,
                                color: Color(0xFF0052FF),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickLogo,
                child: Text(
                  _logoBytes != null ? "Change Company Logo" : "Upload Company Logo",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "PNG or SVG, min 512x512",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Cover Banner Upload Box
        GestureDetector(
          onTap: _pickBanner,
          child: Container(
            width: double.infinity,
            height: _bannerBytes != null ? 100 : null,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _bannerBytes != null
                    ? const Color(0xFF0052FF)
                    : const Color(0xFFCBD5E1),
                width: 1.8,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _bannerBytes != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(_bannerBytes!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Banner Selected",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF4FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF0052FF),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Upload Cover Banner",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0052FF),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Recommended 1200x400",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.file_upload_outlined,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Company Name Input Field
        const Text(
          "Company Name",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _companyNameController,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: "Enter company name",
              prefixIcon: Icon(
                Icons.domain_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Brand Color Row
        const Text(
          "Brand Color",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(_brandColors.length, (index) {
              final isSelected = index == _selectedColorIndex;
              final color = _brandColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Colors.white,
                            width: 3,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                          alpha: isSelected ? 0.45 : 0.15,
                        ),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : null,
                ),
              );
            }),

            // Custom Color Circle with Plus Icon
            GestureDetector(
              onTap: () async {
                final picked = await showCustomColorPicker(
                  context,
                  initialColor: _activeBrandColor,
                );
                if (picked != null && mounted) {
                  setState(() {
                    _customColor = picked;
                  });
                }
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _customColor != null
                      ? _customColor!.withValues(alpha: 0.2)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _customColor != null
                        ? _customColor!
                        : const Color(0xFFCBD5E1),
                    width: _customColor != null ? 2.0 : 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: _customColor ?? const Color(0xFF64748B),
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Toggle Row: Lock Brand Color for All Employees
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Lock brand color for all employees",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _lockBrandColor,
                    activeThumbColor: const Color(0xFF0052FF),
                    activeTrackColor: const Color(0xFF93C5FD),
                    onChanged: (val) {
                      setState(() {
                        _lockBrandColor = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                "Employees cannot override the organization's official brand palette on their digital business cards.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  // --- STEP 2: INVITE YOUR TEAM ---
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline Title
        const Text(
          "Invite Your Team",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Add employees now or share a link later",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 24),

        // Rounded White Card: Reusable Invite Link Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Workspace Invite Link",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // Light Gray Pill-Shaped Text Field showing Link + Copy & Share buttons
              Container(
                padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _inviteLink,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Copy Button
                    GestureDetector(
                      onTap: _copyInviteLink,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text(
                              "Copy",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Share Icon Button
                    IconButton(
                      onPressed: _shareInviteLink,
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Color(0xFF0052FF),
                        size: 20,
                      ),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Divider line with "or invite by email" text
        Row(
          children: [
            const Expanded(
              child: Divider(
                color: Color(0xFFCBD5E1),
                thickness: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "or invite by email",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(
              child: Divider(
                color: Color(0xFFCBD5E1),
                thickness: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Rounded White Input Field: Employee Email + Dynamic "+" / "Add" Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailInputController,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Employee Email (e.g. alex@company.com)",
                    prefixIcon: Icon(
                      Icons.mail_outline_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _addEmail(),
                ),
              ),

              // Dynamic "+" / "Add" Button Attached to Right
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: _addEmail,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: _emailInputController.text.trim().isNotEmpty
                        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
                        : const EdgeInsets.all(8),
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052FF),
                      borderRadius: _emailInputController.text.trim().isNotEmpty
                          ? BorderRadius.circular(12)
                          : BorderRadius.circular(19),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _emailInputController.text.trim().isNotEmpty
                          ? const Row(
                              key: ValueKey('add_text_button'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Add",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Icon(
                              Icons.add_rounded,
                              key: ValueKey('plus_icon_button'),
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Vertical List of Added Email Chips (Rounded Pill Shapes)
        if (_invitedEmails.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Invited Team Members",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(_invitedEmails.length, (index) {
                final email = _invitedEmails[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDBEAFE), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alternate_email_rounded,
                        color: Color(0xFF0052FF),
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removeEmail(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE2E8F0),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF64748B),
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),

        const SizedBox(height: 20),

        // Helper Text
        const Center(
          child: Text(
            "You can invite more employees anytime from your dashboard",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }

  // --- STEP 3: ALMOST SET UP! ---
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline Title
        const Text(
          "Almost Set Up!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "A few final details for your workspace",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 24),

        // Company Website Input Field
        const Text(
          "Company Website",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _websiteController,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: "https://...",
              prefixIcon: Icon(
                Icons.language_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Company Address Input Field
        const Text(
          "Company Address",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _addressController,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
            decoration: const InputDecoration(
              hintText: "Street, City, Country",
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: Color(0xFF64748B),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Employee Limit Dropdown Field
        const Text(
          "Employee Limit",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          constraints: const BoxConstraints(minWidth: 280),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          elevation: 10,
          onSelected: (String newValue) {
            setState(() {
              _selectedEmployeeLimit = newValue;
            });
          },
          itemBuilder: (BuildContext context) {
            return _employeeLimitOptions.map((String value) {
              final isSelected = value == _selectedEmployeeLimit;
              return PopupMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      color: isSelected
                          ? const Color(0xFF0052FF)
                          : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0052FF)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_outline_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedEmployeeLimit,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Based on your Enterprise Pro plan",
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 28),

        // Workspace Summary Section Header
        const Text(
          "WORKSPACE SUMMARY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 10),

        // Rounded Light-Blue Tinted Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFDBEAFE),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Small Company Logo Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  gradient: _logoBytes == null
                      ? const LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _logoBytes != null
                    ? ClipOval(
                        child: Image.memory(
                          _logoBytes!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _companyNameController.text.trim().isNotEmpty
                          ? _companyNameController.text.trim()
                          : "Your Company Name",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Brand Color Swatch Dot
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _activeBrandColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${_invitedEmails.length} employees invited",
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
      ],
    );
  }
}
