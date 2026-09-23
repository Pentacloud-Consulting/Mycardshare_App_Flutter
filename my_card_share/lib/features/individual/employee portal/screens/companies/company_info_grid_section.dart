import 'package:flutter/material.dart';

class CompanyInfoGridSection extends StatelessWidget {
  final String location;
  final String website;
  final String role;
  final String joinedDate;

  const CompanyInfoGridSection({
    super.key,
    this.location = "New York, NY",
    this.website = "acmerealty.com",
    this.role = "Employee",
    this.joinedDate = "March 2026",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFEF2F2),
                label: "Location",
                value: location,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF0052FF),
                iconBg: const Color(0xFFEFF6FF),
                label: "Website",
                value: website,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.person_rounded,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFFF3E8FF),
                label: "Your Role",
                value: role,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTile(
                icon: Icons.calendar_today_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
                label: "Joined",
                value: joinedDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
