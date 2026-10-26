import 'package:flutter/material.dart';
import '../../../../backend/number logic/phone_number_service.dart';

class ProfileContactDetails extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController? companyEmailController;
  final TextEditingController websiteController;
  final ValueChanged<bool>? onValidationChanged;

  const ProfileContactDetails({
    super.key,
    required this.phoneController,
    required this.emailController,
    this.companyEmailController,
    required this.websiteController,
    this.onValidationChanged,
  });

  @override
  State<ProfileContactDetails> createState() => _ProfileContactDetailsState();
}

class _ProfileContactDetailsState extends State<ProfileContactDetails> {
  String? _phoneError;
  bool _isValidPhone = false;

  @override
  void initState() {
    super.initState();
    _validateInitialPhone();
    widget.phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_onPhoneChanged);
    super.dispose();
  }

  void _validateInitialPhone() {
    final text = widget.phoneController.text.trim();
    if (text.isNotEmpty) {
      final validation = PhoneValidationModel.validateLocal(text);
      _isValidPhone = validation.isValid;
      _phoneError = validation.isValid ? null : validation.errorMessage;
    }
  }

  void _onPhoneChanged() {
    final text = widget.phoneController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _phoneError = null;
        _isValidPhone = false;
      });
      widget.onValidationChanged?.call(true);
      return;
    }

    final validation = PhoneValidationModel.validateLocal(text);
    setState(() {
      _isValidPhone = validation.isValid;
      _phoneError = validation.isValid ? null : validation.errorMessage;
    });
    widget.onValidationChanged?.call(validation.isValid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Contact Details",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Phone Field with Live Validation (Fixes 9729041 bug)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _phoneError != null
                  ? const Color(0xFFEF4444)
                  : (_isValidPhone ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0)),
              width: _phoneError != null ? 1.4 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: _phoneError != null
                      ? const Color(0xFFEF4444)
                      : (_isValidPhone ? const Color(0xFF16A34A) : const Color(0xFF64748B)),
                  size: 18,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: Text(
                    "Phone *",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _phoneError != null ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: widget.phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      counterText: "",
                      hintText: "e.g. 9876543210",
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (_isValidPhone) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 12),
                        SizedBox(width: 4),
                        Text(
                          "Valid",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Live Error Alert for Phone
        if (_phoneError != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFDC2626)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _phoneError!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 8),

        // 1. Employee Email Field (Verified & Read-only)
        _buildInputField(
          icon: Icons.mail_outline_rounded,
          label: "Employee Email",
          controller: widget.emailController,
          isReadOnly: true,
          isVerified: true,
        ),
        const SizedBox(height: 8),

        // 2. Enterprise Company Email Field (Verified & Read-only)
        _buildInputField(
          icon: Icons.business_rounded,
          label: "Company Email",
          controller: widget.companyEmailController ?? TextEditingController(),
          isReadOnly: true,
          isVerified: true,
        ),
        const SizedBox(height: 8),

        // 3. Website Link (Auto-fetched from Enterprise, Non-editable Read-only)
        _buildInputField(
          icon: Icons.language_rounded,
          label: "Website",
          controller: widget.websiteController,
          isReadOnly: true,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool isReadOnly = false,
    bool isVerified = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 18),
            const SizedBox(width: 10),
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: isReadOnly,
                enabled: !isReadOnly,
                style: TextStyle(
                  fontSize: 13,
                  color: isReadOnly ? const Color(0xFF475569) : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 12),
                    SizedBox(width: 4),
                    Text(
                      "Verified",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
