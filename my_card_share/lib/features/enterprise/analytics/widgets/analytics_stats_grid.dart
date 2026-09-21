import 'package:flutter/material.dart';

class AnalyticsStatsGrid extends StatelessWidget {
  final String totalViews;
  final String qrScans;
  final String leadsCaptured;
  final String avgConvRate;

  const AnalyticsStatsGrid({
    super.key,
    this.totalViews = "8,420",
    this.qrScans = "2,140",
    this.leadsCaptured = "312",
    this.avgConvRate = "5.2%",
  });

  @override
  Widget build(BuildContext context) {
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
          badgeText: "+18%",
          value: totalViews,
          label: "Total Views",
        ),
        _buildStatCard(
          icon: Icons.qr_code_2_rounded,
          iconBgColor: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7C3AED),
          badgeText: "+22%",
          value: qrScans,
          label: "QR Scans",
        ),
        _buildStatCard(
          icon: Icons.groups_rounded,
          iconBgColor: const Color(0xFFCCFBF1),
          iconColor: const Color(0xFF0D9488),
          badgeText: "+24%",
          value: leadsCaptured,
          label: "Leads Captured",
        ),
        _buildStatCard(
          icon: Icons.bar_chart_rounded,
          iconBgColor: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          badgeText: "+0.6%",
          value: avgConvRate,
          label: "Avg Conv. Rate",
        ),
      ],
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
