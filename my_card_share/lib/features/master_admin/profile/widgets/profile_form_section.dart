import 'package:flutter/material.dart';

class ProfileFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const ProfileFormSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Full Name Field
        _buildInputField(
          label: "Full Name",
          controller: nameController,
          icon: Icons.person_outline_rounded,
          hint: "System Master Admin",
        ),
        const SizedBox(height: 12),

        // Email Address Field (Read-only style with Lock Icon)
        _buildInputField(
          label: "Email Address",
          controller: emailController,
          icon: Icons.mail_outline_rounded,
          readOnly: true,
          suffixIcon: const Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: Color(0xFF94A3B8),
          ),
          hint: "admin@mycardshare.com",
        ),
        const SizedBox(height: 12),

        // Phone Number Field
        _buildInputField(
          label: "Phone Number",
          controller: phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          hint: "+1 (555) 019-2834",
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: readOnly ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: readOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: readOnly ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            size: 20,
          ),
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
        ),
      ),
    );
  }
}
