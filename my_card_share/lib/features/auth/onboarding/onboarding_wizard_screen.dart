import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_style_widgets.dart';
import '../../../providers/auth_provider.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> {
  int _currentStep = 1; // 1: Profile & Template, 2: Social Links, 3: Bio & Preview

  // Step 1 Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int _selectedTemplate = 0; // 0: Alex, 1: Sarah, 2: Daniel, 3: Mohammed

  // Step 2 Social Link Controllers
  final TextEditingController _linkedInController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final List<TextEditingController> _customLinkControllers = [];

  // Step 3 Controllers
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _shortBioController = TextEditingController();
  String _networkingStatus = 'Actively Networking';

  final List<String> _statusOptions = [
    'Actively Networking',
    'Open to Opportunities',
    'Hiring',
    'Busy',
  ];

  @override
  void initState() {
    super.initState();
    _shortBioController.addListener(() {
      if (mounted) setState(() {});
    });
    _companyNameController.addListener(() {
      if (mounted) setState(() {});
    });
    _jobTitleController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _phoneController.dispose();

    _linkedInController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    _websiteController.dispose();
    _githubController.dispose();
    _youtubeController.dispose();

    _companyNameController.dispose();
    _shortBioController.dispose();

    for (var c in _customLinkControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      _onFinishWizard();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _addCustomLink() {
    setState(() {
      _customLinkControllers.add(TextEditingController());
    });
  }

  void _onFinishWizard() {
    final role = ref.read(authProvider).role;
    if (role == 'master-admin') {
      context.go('/master-admin/dashboard');
    } else if (role == 'enterprise') {
      context.go('/enterprise/dashboard');
    } else {
      context.go('/portal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top Right Ambient Blue Gradient Circle
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom Left Ambient Light Glow
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Fixed Top Header: Progress Indicator Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildProgressBarItem(stepIndex: 1),
                          const SizedBox(width: 8),
                          _buildProgressBarItem(stepIndex: 2),
                          const SizedBox(width: 8),
                          _buildProgressBarItem(stepIndex: 3),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Step $_currentStep of 3",
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle Scrollable Body Content (Mobile Responsive)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentStep == 1) _buildStep1Content(),
                        if (_currentStep == 2) _buildStep2Content(),
                        if (_currentStep == 3) _buildStep3Content(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar Container: Continue & Skip (SafeArea padded for all phone sizes)
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 12.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.3, 1.0],
                        colors: [
                          AppColors.background.withValues(alpha: 0.0),
                          AppColors.background.withValues(alpha: 0.85),
                          AppColors.background,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClayButton(
                          label: _currentStep == 3 ? "Complete Setup" : "Continue",
                          icon: Icons.arrow_forward_rounded,
                          onTap: _nextStep,
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: _nextStep,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Skip for now",
                              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildProgressBarItem({required int stepIndex}) {
    final isActive = _currentStep >= stepIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentStep = stepIndex;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  // ==================== STEP 1: SET UP PROFILE & TEMPLATE ====================
  Widget _buildStep1Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Up Your Profile",
          style: AppTextStyles.textTheme.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "This is how people will see you",
          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 24),

        // Dashed Circle Avatar Uploader with Camera Badge
        Center(
          child: Column(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(110, 110),
                      painter: DashedAvatarCirclePainter(),
                    ),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 52,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
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
              ),
              const SizedBox(height: 8),
              Text(
                "Upload Photo",
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Job Title Field
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _jobTitleController,
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Job Title",
              hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.work_outline_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Phone Number Field
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: "Phone Number",
              hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: AppColors.textMuted,
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Choose a Template Header
        Text(
          "Choose a Template",
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        // Template Cards Horizontal Scroll Row
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTemplateCard(
                index: 0,
                name: "Alex Carter",
                role: "Product Designer",
                gradient: const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                badgeColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _buildTemplateCard(
                index: 1,
                name: "Sarah Khan",
                role: "Marketing Manager",
                gradient: const [Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                badgeColor: const Color(0xFFA855F7),
              ),
              const SizedBox(width: 12),
              _buildTemplateCard(
                index: 2,
                name: "Daniel Lee",
                role: "Sales Consultant",
                gradient: const [Color(0xFFCCFBF1), Color(0xFF99F6E4)],
                badgeColor: const Color(0xFF0D9488),
              ),
              const SizedBox(width: 12),
              _buildTemplateCard(
                index: 3,
                name: "Mohammed Ali",
                role: "Software Engineer",
                gradient: const [Color(0xFF0F172A), Color(0xFF1E293B)],
                badgeColor: const Color(0xFF38B6FF),
                isDark: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== STEP 2: ADD YOUR LINKS ====================
  Widget _buildStep2Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _prevStep,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Add Your Links",
                style: AppTextStyles.textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "People can tap to connect with you instantly",
          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 24),

        // Social Links List Cards
        _buildSocialLinkRow(
          label: "LinkedIn",
          iconWidget: _buildBrandIcon(
            backgroundColor: const Color(0xFF0077B5),
            child: const FaIcon(
              FontAwesomeIcons.linkedinIn,
              color: Colors.white,
              size: 18,
            ),
          ),
          hintText: "@username",
          controller: _linkedInController,
        ),

        const SizedBox(height: 12),

        _buildSocialLinkRow(
          label: "Instagram",
          iconWidget: Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF77737)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.instagram,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          hintText: "@username",
          controller: _instagramController,
        ),

        const SizedBox(height: 12),

        _buildSocialLinkRow(
          label: "WhatsApp",
          iconWidget: _buildBrandIcon(
            backgroundColor: const Color(0xFF25D366),
            child: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.white,
              size: 20,
            ),
          ),
          hintText: "+91 98765 43210",
          controller: _whatsappController,
        ),

        const SizedBox(height: 12),

        _buildSocialLinkRow(
          label: "Website",
          iconWidget: _buildBrandIcon(
            backgroundColor: const Color(0xFF475569),
            child: const FaIcon(
              FontAwesomeIcons.globe,
              color: Colors.white,
              size: 18,
            ),
          ),
          hintText: "https://yourwebsite.com",
          controller: _websiteController,
        ),

        const SizedBox(height: 12),

        _buildSocialLinkRow(
          label: "GitHub",
          iconWidget: _buildBrandIcon(
            backgroundColor: const Color(0xFF0F172A),
            child: const FaIcon(
              FontAwesomeIcons.github,
              color: Colors.white,
              size: 19,
            ),
          ),
          hintText: "@username",
          controller: _githubController,
        ),

        const SizedBox(height: 12),

        _buildSocialLinkRow(
          label: "YouTube",
          iconWidget: _buildBrandIcon(
            backgroundColor: const Color(0xFFFF0000),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
          ),
          hintText: "@username",
          controller: _youtubeController,
        ),

        // Custom Links List
        for (int i = 0; i < _customLinkControllers.length; i++) ...[
          const SizedBox(height: 12),
          _buildSocialLinkRow(
            label: "Custom",
            iconWidget: _buildBrandIcon(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.link_rounded, color: Colors.white, size: 22),
            ),
            hintText: "https://link.com",
            controller: _customLinkControllers[i],
          ),
        ],

        const SizedBox(height: 18),

        // + Add Custom Link Dashed Button
        CustomPaint(
          painter: DashedRectPainter(
            color: AppColors.primary,
            strokeWidth: 1.5,
            gap: 5,
            radius: 16,
          ),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _addCustomLink,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Add Custom Link",
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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

  // Helper method to build brand icon badge
  Widget _buildBrandIcon({required Color backgroundColor, required Widget child}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }

  // Helper method to build social link row container (Fully Responsive for narrow screens)
  Widget _buildSocialLinkRow({
    required String label,
    required Widget iconWidget,
    required String hintText,
    required TextEditingController controller,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final labelWidth = screenWidth < 360 ? 68.0 : 84.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 10),
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                fontSize: screenWidth < 360 ? 13.5 : 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 3: ALMOST THERE! ====================
  Widget _buildStep3Content() {
    final companyText = _companyNameController.text.trim();
    final displayCompany = companyText.isNotEmpty ? companyText : "Acme Inc.";

    final jobTitleText = _jobTitleController.text.trim();
    final displayRole = jobTitleText.isNotEmpty ? jobTitleText : "Product Designer";

    final userName = ref.watch(authProvider).user?.name ?? "Alex Stanton";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _prevStep,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: AppColors.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Almost There!",
                style: AppTextStyles.textTheme.headlineLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "A few final details for your card",
          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),

        const SizedBox(height: 24),

        // Company Name Field Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.apartment_rounded,
                color: AppColors.textSecondary,
                size: 26,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Company Name",
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TextField(
                      controller: _companyNameController,
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "e.g. Acme Inc.",
                        hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Short Bio Field Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Short Bio",
                          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _shortBioController,
                          maxLength: 200,
                          maxLines: 3,
                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hintText: "Tell people a bit about yourself...\ne.g. I design digital products and love building...",
                            hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_shortBioController.text.length}/200",
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Networking Status Card Field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "Networking Status",
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  setState(() {
                    _networkingStatus = val;
                  });
                },
                itemBuilder: (context) => _statusOptions.map((opt) {
                  return PopupMenuItem<String>(
                    value: opt,
                    child: Text(opt),
                  );
                }).toList(),
                child: GlassPill(
                  label: _networkingStatus,
                  dotColor: AppColors.success,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Live Preview Header
        Center(
          child: Text(
            "LIVE PREVIEW",
            style: AppTextStyles.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Live Card Preview Container (ClayCard / Morphic)
        ClayCard(
          padding: const EdgeInsets.all(20),
          radius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=300",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppTextStyles.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayRole,
                          style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.apartment_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              displayCompany,
                              style: AppTextStyles.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
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
              if (_shortBioController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _shortBioController.text.trim(),
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Template Card Builder
  Widget _buildTemplateCard({
    required int index,
    required String name,
    required String role,
    required List<Color> gradient,
    required Color badgeColor,
    bool isDark = false,
  }) {
    final isSelected = _selectedTemplate == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplate = index;
        });
      },
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.25) : const Color(0x0A000000),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 22),
                Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: badgeColor.withValues(alpha: 0.2),
                      child: Icon(Icons.person, size: 26, color: badgeColor),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniCircleIcon(Icons.phone, badgeColor),
                      const SizedBox(width: 3),
                      _buildMiniCircleIcon(Icons.mail, badgeColor),
                      const SizedBox(width: 3),
                      _buildMiniCircleIcon(Icons.share, badgeColor),
                      const SizedBox(width: 3),
                      _buildMiniCircleIcon(Icons.link, badgeColor),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCircleIcon(IconData icon, Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 8, color: color),
    );
  }
}

// Dashed Circle Custom Painter for Avatar Uploader
class DashedAvatarCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    double dashWidth = 5;
    double dashSpace = 4;
    double circumference = 2 * 3.141592653589793 * radius;
    int count = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < count; i++) {
      double startAngle = (i * (dashWidth + dashSpace) / radius);
      double sweepAngle = (dashWidth / radius);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Dashed Rectangle Painter for Add Custom Link Button
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 5,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = distance + gap;
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance += gap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
