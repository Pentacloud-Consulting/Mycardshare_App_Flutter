import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_style_widgets.dart';
import '../../../providers/vault_provider.dart';
import '../../../backend/individual/scan/card_scan_service.dart';
import '../../../backend/individual/scan/voice_add_service.dart';
import '../../../backend/individual/scan/manual_entry_service.dart';
import '../../../backend/individual/scan/edit_scan.dart';

class ReviewDetailsScreen extends ConsumerStatefulWidget {
  final String tag; // 'OCR', 'Voice', 'Manual'
  final String? initialName;
  final String? initialRole;
  final String? initialCompany;
  final String? initialPhone;
  final String? initialEmail;
  final String? initialWebsite;
  final String? initialAddress;
  final String? initialImagePath;

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
    this.initialImagePath,
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
    _fullNameController = TextEditingController(text: widget.initialName ?? '');
    _jobTitleController = TextEditingController(text: widget.initialRole ?? '');
    _companyController = TextEditingController(text: widget.initialCompany ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _websiteController = TextEditingController(text: widget.initialWebsite ?? '');
    _addressController = TextEditingController(text: widget.initialAddress ?? '');
    _noteController = TextEditingController();
    // Rebuild when any field changes so card preview stays live
    for (final c in [
      _fullNameController, _jobTitleController, _companyController,
      _phoneController, _emailController, _websiteController, _addressController,
    ]) {
      c.addListener(() => setState(() {}));
    }
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

  void _saveToVault() async {
    final editData = EditScanData(
      name: _fullNameController.text.trim(),
      role: _jobTitleController.text.trim(),
      company: _companyController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      website: _websiteController.text.trim(),
      address: _addressController.text.trim(),
      note: _noteController.text.trim(),
      tag: widget.tag,
      imagePath: widget.initialImagePath,
    );

    final errors = EditScanService.instance.validateAll(editData);
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠ ${errors.values.first}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final id = 'scan_${DateTime.now().millisecondsSinceEpoch}';
    final contact = editData.toScannedContact(id);

    if (widget.tag == 'Voice') {
      await VoiceAddService.instance.saveVoiceContact(contact);
    } else if (widget.tag == 'Manual') {
      await ManualEntryService.instance.saveManualContact(contact);
    } else {
      await CardScanService.instance.saveScannedContact(contact);
    }

    ref.read(vaultNotifierProvider.notifier).addContact({
      'name': contact.name,
      'role': contact.role,
      'company': contact.company,
      'dateAdded': 'Just now',
      'tag': contact.tag,
    });

    if (!mounted) return;
    if (Navigator.canPop(context)) Navigator.pop(context);
    context.push('/portal/vault');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ ${contact.name} saved to Contact Vault!'),
        backgroundColor: const Color(0xFF0052FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    // Live card preview — updates as user edits fields
                    _buildLiveCardPreview(),

                    const SizedBox(height: 20),

                    // Editable form fields — tap pencil icon to edit inline
                    _buildEditFieldCard(
                      icon: Icons.person_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'FULL NAME',
                      controller: _fullNameController,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.work_rounded,
                      iconColor: const Color(0xFF0284C7),
                      label: 'JOB TITLE',
                      controller: _jobTitleController,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.apartment_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'COMPANY',
                      controller: _companyController,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.phone_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'PHONE',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.mail_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'EMAIL',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.language_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'WEBSITE',
                      controller: _websiteController,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'ADDRESS',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 10),
                    _buildEditFieldCard(
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF0066FF),
                      label: 'NOTE (OPTIONAL)',
                      controller: _noteController,
                      hintText: 'Add a note... e.g. Met at TechExpo 2026',
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

  // ── Live card preview ────────────────────────────────────────────────────

  Widget _buildLiveCardPreview() {
    final name = _fullNameController.text.isNotEmpty
        ? _fullNameController.text
        : 'Full Name';
    final role = _jobTitleController.text.isNotEmpty
        ? _jobTitleController.text
        : 'Job Title';
    final company = _companyController.text.isNotEmpty
        ? _companyController.text
        : 'Company';
    final phone = _phoneController.text;
    final email = _emailController.text;
    final website = _websiteController.text;
    final address = _addressController.text;

    final hasImage = widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty &&
        File(widget.initialImagePath!).existsSync();

    return Column(
      children: [
        if (hasImage) ...[
          Container(
            width: double.infinity,
            height: 140,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0052FF).withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  kIsWeb
                      ? Image.network(
                          widget.initialImagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF1E293B),
                            child: const Center(
                              child: Icon(Icons.credit_card, color: Colors.white70, size: 36),
                            ),
                          ),
                        )
                      : Image.file(
                          File(widget.initialImagePath!),
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.style_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Scanned Card Image',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        if (phone.isNotEmpty) _buildMiniContactRow(Icons.phone_rounded, phone),
                        if (email.isNotEmpty) ...[const SizedBox(height: 4), _buildMiniContactRow(Icons.mail_outline_rounded, email)],
                        if (website.isNotEmpty) ...[const SizedBox(height: 4), _buildMiniContactRow(Icons.language_rounded, website)],
                        if (address.isNotEmpty) ...[const SizedBox(height: 4), _buildMiniContactRow(Icons.location_on_outlined, address)],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Company initial badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      company.isNotEmpty && company != 'Company'
                          ? company.substring(0, 1).toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: Color(0xFF0052FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // OCR badge
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Color(0x3300C853), blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'AI Extracted',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
            style: const TextStyle(
                fontSize: 9.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  /// Editable field card — tapping the pencil icon opens EditScanService inline sheet.
  Widget _buildEditFieldCard({
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
                Text(
                  controller.text.isNotEmpty ? controller.text : (hintText ?? '—'),
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: controller.text.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Pencil edit button — opens inline edit sheet
          GestureDetector(
            onTap: () async {
              final newValue = await EditScanService.instance.showInlineEditSheet(
                context,
                fieldLabel: label.replaceAll(' (OPTIONAL)', ''),
                currentValue: controller.text,
                keyboardType: keyboardType ?? TextInputType.text,
              );
              if (newValue != null) {
                setState(() => controller.text = newValue);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}


