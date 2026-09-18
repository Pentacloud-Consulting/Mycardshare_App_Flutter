import 'package:flutter/material.dart';

class ProfileBasicInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController roleController;
  final TextEditingController companyController;
  final TextEditingController bioController;

  const ProfileBasicInfo({
    super.key,
    required this.nameController,
    required this.roleController,
    required this.companyController,
    required this.bioController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Basic Info",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Full Name Field
        _buildInputField(
          icon: Icons.person_outline_rounded,
          label: "Full Name",
          controller: nameController,
        ),
        const SizedBox(height: 8),

        // Job Title Field
        _buildInputField(
          icon: Icons.work_outline_rounded,
          label: "Job Title",
          controller: roleController,
        ),
        const SizedBox(height: 8),

        // Company Name Field
        _buildInputField(
          icon: Icons.apartment_rounded,
          label: "Company Name",
          controller: companyController,
        ),
        const SizedBox(height: 8),

        // Bio Field
        _buildInputField(
          icon: Icons.edit_outlined,
          label: "Bio",
          controller: bioController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
          crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
              child: Icon(icon, color: const Color(0xFF64748B), size: 18),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 90,
              child: Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
