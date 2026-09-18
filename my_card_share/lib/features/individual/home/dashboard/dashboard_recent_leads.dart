import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardRecentLeads extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const DashboardRecentLeads({
    super.key,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Leads",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onSeeAllTap ?? () => context.go('/portal/leads'),
              child: const Text(
                "See All",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLeadItem(
          initial: "J",
          avatarBg: const Color(0xFFE0F2FE),
          initialColor: const Color(0xFF0284C7),
          name: "James Miller",
          company: "TechNova Solutions",
          source: "via QR scan",
          time: "2h ago",
        ),
        const SizedBox(height: 8),
        _buildLeadItem(
          initial: "P",
          avatarBg: const Color(0xFFF3E8FF),
          initialColor: const Color(0xFF9333EA),
          name: "Priya Sharma",
          company: "GrowthNest Media",
          source: "via QR scan",
          time: "5h ago",
        ),
        const SizedBox(height: 8),
        _buildLeadItem(
          initial: "D",
          avatarBg: const Color(0xFFDCFCE7),
          initialColor: const Color(0xFF16A34A),
          name: "Daniel Kim",
          company: "Skyline Ventures",
          source: "via QR scan",
          time: "1d ago",
        ),
      ],
    );
  }

  Widget _buildLeadItem({
    required String initial,
    required Color avatarBg,
    required Color initialColor,
    required String name,
    required String company,
    required String source,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: initialColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              source,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
