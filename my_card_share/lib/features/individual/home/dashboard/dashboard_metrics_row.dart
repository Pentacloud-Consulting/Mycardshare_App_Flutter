import 'package:flutter/material.dart';

class DashboardMetricsRow extends StatelessWidget {
  final String views;
  final String viewsTrend;
  final String leads;
  final String leadsTrend;
  final String scans;
  final String scansTrend;

  const DashboardMetricsRow({
    super.key,
    this.views = "1,420",
    this.viewsTrend = "+24%",
    this.leads = "32",
    this.leadsTrend = "+18%",
    this.scans = "310",
    this.scansTrend = "+42%",
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.visibility_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF0066FF),
            title: "Views",
            value: views,
            trend: viewsTrend,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.person_add_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF9333EA),
            title: "Leads",
            value: leads,
            trend: leadsTrend,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.grid_view_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
            title: "Scans",
            value: scans,
            trend: scansTrend,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.north_east_rounded,
                color: Color(0xFF16A34A),
                size: 13,
              ),
              const SizedBox(width: 2),
              Text(
                "$trend ",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF16A34A),
                ),
              ),
              const Flexible(
                child: Text(
                  "this week",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
