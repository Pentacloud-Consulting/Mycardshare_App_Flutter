import 'package:flutter/material.dart';

class ProfileBasicInfo extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController roleController;
  final TextEditingController companyController;
  final TextEditingController bioController;
  final TextEditingController? experienceController;
  final TextEditingController? cityController;
  final bool isCompanyLocked;

  const ProfileBasicInfo({
    super.key,
    required this.nameController,
    required this.roleController,
    required this.companyController,
    required this.bioController,
    this.experienceController,
    this.cityController,
    this.isCompanyLocked = false,
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

        // Company Name Field (Locks if belonging to Enterprise workspace)
        _buildInputField(
          icon: Icons.apartment_rounded,
          label: "Company Name",
          controller: companyController,
          isReadOnly: isCompanyLocked,
          trailingBadge: isCompanyLocked
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_rounded, size: 11, color: Color(0xFF64748B)),
                      SizedBox(width: 3),
                      Text(
                        "Managed",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),

        // Bio Field
        _buildInputField(
          icon: Icons.edit_outlined,
          label: "Bio",
          controller: bioController,
          maxLines: 3,
        ),

        // Experience Field
        if (experienceController != null) ...[
          const SizedBox(height: 8),
          _buildInputField(
            icon: Icons.history_edu_rounded,
            label: "Experience",
            controller: experienceController!,
            maxLines: 3,
          ),
        ],

        // City / Location Field
        if (cityController != null) ...[
          const SizedBox(height: 8),
          _buildInputField(
            icon: Icons.location_on_outlined,
            label: "City / Location",
            controller: cityController!,
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool isReadOnly = false,
    Widget? trailingBadge,
  }) {
    if (maxLines == 1) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 18,
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 108,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: isReadOnly,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  color: isReadOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (trailingBadge != null) ...[
              const SizedBox(width: 8),
              trailingBadge,
            ],
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isReadOnly ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isReadOnly ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            TextField(
              controller: controller,
              readOnly: isReadOnly,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 13,
                color: isReadOnly ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
