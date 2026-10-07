import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/home_backend/overall.dart';

class AnalyticsStatsGrid extends StatelessWidget {
  const AnalyticsStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<OverallEnterpriseStats>(
      stream: EnterpriseOverallService.instance.streamOverallStats(uid),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? OverallEnterpriseStats.empty("Admin");

        final totalViews = stats.totalCardViews > 1000
            ? "${(stats.totalCardViews / 1000).toStringAsFixed(1)}k"
            : "${stats.totalCardViews}";

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: [
            _buildStatCard(
              icon: Icons.visibility_rounded,
              iconBgColor: const Color(0xFFEFF4FF),
              iconColor: const Color(0xFF0052FF),
              badgeText: "+${stats.totalCardViews > 0 ? '18%' : '0%'}",
              value: totalViews,
              label: "Total Views",
            ),
            _buildStatCard(
              icon: Icons.people_alt_rounded,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF7C3AED),
              badgeText: "+${stats.totalEmployees}",
              value: "${stats.totalEmployees}",
              label: "Team Members",
            ),
            _buildStatCard(
              icon: Icons.groups_rounded,
              iconBgColor: const Color(0xFFCCFBF1),
              iconColor: const Color(0xFF0D9488),
              badgeText: "+${stats.totalLeads > 0 ? '24%' : '0%'}",
              value: "${stats.totalLeads}",
              label: "Leads Captured",
            ),
            _buildStatCard(
              icon: Icons.bar_chart_rounded,
              iconBgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              badgeText: stats.convRate,
              value: stats.convRate,
              label: "Avg Conv. Rate",
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String badgeText,
    required String value,
    required String label,
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


