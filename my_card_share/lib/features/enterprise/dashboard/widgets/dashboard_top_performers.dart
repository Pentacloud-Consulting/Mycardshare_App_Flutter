import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardTopPerformers extends StatelessWidget {
  const DashboardTopPerformers({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Top Performers",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/enterprise/workspace'),
              child: const Text(
                "See All",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0052FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLeaderboardRow(
          rank: 1,
          rankBgColor: const Color(0xFFFEF3C7),
          rankTextColor: const Color(0xFFD97706),
          hasTrophy: true,
          name: "Sarah Jenkins",
          subtitle: "142 views · 12 leads",
          initials: "SJ",
        ),
        const SizedBox(height: 10),
        _buildLeaderboardRow(
          rank: 2,
          rankBgColor: const Color(0xFFF1F5F9),
          rankTextColor: const Color(0xFF475569),
          hasTrophy: false,
          name: "David Miller",
          subtitle: "118 views · 9 leads",
          initials: "DM",
        ),
        const SizedBox(height: 10),
        _buildLeaderboardRow(
          rank: 3,
          rankBgColor: const Color(0xFFFFEDD5),
          rankTextColor: const Color(0xFFC2410C),
          hasTrophy: false,
          name: "Emily Turner",
          subtitle: "96 views · 7 leads",
          initials: "ET",
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow({
    required int rank,
    required Color rankBgColor,
    required Color rankTextColor,
    required bool hasTrophy,
    required String name,
    required String subtitle,
    required String initials,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: rankBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$rank",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: rankTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEFF4FF),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0052FF),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Employee Name & Metrics
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          if (hasTrophy)
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFD97706),
              size: 20,
            ),
        ],
      ),
    );
  }
}
