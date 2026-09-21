import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_style_widgets.dart';
import '../../../providers/vault_provider.dart';

class ReviewDetailsScreen extends ConsumerStatefulWidget {
  final String tag; // 'OCR', 'Voice', 'Manual'
  final String? initialName;
  final String? initialRole;
  final String? initialCompany;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialWebsite;
  final String? initialAddress;

  const ReviewDetailsScreen({
    super.key,
    this.tag = 'OCR',
    this.initialName,
    this.initialRole,
    this.initialCompany,
    this.initialPhone,
    this.initialEmail,
    this.initialWebsite,
    this.initialAddress,
  });

  @override
  ConsumerState<ReviewDetailsScreen> createState() => _ReviewDetailsScreenState();
}

class _ReviewDetailsScreenState extends ConsumerState<ReviewDetailsScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialName ?? "Robert Chen");
    _jobTitleController = TextEditingController(text: widget.initialRole ?? "Managing Director");
    _companyController = TextEditingController(text: widget.initialCompany ?? "Apex Global Ventures");
    _phoneController = TextEditingController(text: widget.initialPhone ?? "+1-555-4321");
    _emailController = TextEditingController(text: widget.initialEmail ?? "r.chen@apexglobal.com");
    _websiteController = TextEditingController(text: widget.initialWebsite ?? "apexglobal.com");
    _addressController = TextEditingController(text: widget.initialAddress ?? "500 California St, San Francisco, CA");
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveToVault() {
    final name = _fullNameController.text.trim();
    final role = _jobTitleController.text.trim();
    final company = _companyController.text.trim();

    ref.read(vaultNotifierProvider.notifier).addContact({
      'name': name.isNotEmpty ? name : 'Robert Chen',
      'role': role.isNotEmpty ? role : 'Managing Director',
      'company': company.isNotEmpty ? company : 'Apex Global Ventures',
      'dateAdded': 'Just now',
      'tag': widget.tag,
    });

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    context.push('/portal/vault');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✓ $name saved to Contact Vault (${widget.tag})!"),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review Details",
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Image 4 Top Business Card Preview (Apex Global Ventures)
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE2E8F0), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background decorative shapes
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: 140,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0B132B),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Robert Chen",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const Text(
                                            "Managing Director",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildMiniContactRow(Icons.phone_rounded, "+1 555 4321"),
                                          const SizedBox(height: 4),
                                          _buildMiniContactRow(Icons.mail_outline_rounded, "r.chen@apexglobal.com"),
                                          const SizedBox(height: 4),
                                          _buildMiniContactRow(Icons.language_rounded, "apexglobal.com"),
                                          const SizedBox(height: 4),
                                          _buildMiniContactRow(Icons.location_on_outlined, "500 California St, CA"),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.change_history_rounded, color: Color(0xFF00A2FF), size: 36),
                                        SizedBox(height: 4),
                                        Text(
                                          "APEX",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5),
                                        ),
                                        Text(
                                          "GLOBAL VENTURES",
                                          style: TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 1),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Green "94% Match" Badge Pill
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3300C853),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "94% Match",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Form Fields
                    _buildReviewFieldCard(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "FULL NAME",
                      controller: _fullNameController,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.work_rounded,
                      iconColor: const Color(0xFF0284C7),
                      label: "JOB TITLE",
                      controller: _jobTitleController,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.apartment_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "COMPANY",
                      controller: _companyController,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "PHONE",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.mail_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "EMAIL",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "WEBSITE",
                      controller: _websiteController,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "ADDRESS",
                      controller: _addressController,
                    ),

                    const SizedBox(height: 10),

                    _buildReviewFieldCard(
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: "NOTE (OPTIONAL)",
                      controller: _noteController,
                      hintText: "Add a note... e.g. Met at TechExpo 2026",
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons: Save to Vault & Discard
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClayButton(
                      label: "Save to Vault",
                      onTap: _saveToVault,
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Discard",
                        style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildMiniContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 10, color: const Color(0xFF0066FF)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewFieldCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}
