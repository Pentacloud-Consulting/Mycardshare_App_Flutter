import 'package:flutter/material.dart';

class AnalyticsStatsGrid extends StatelessWidget {
  final String activeTab;

  const AnalyticsStatsGrid({
    super.key,
    this.activeTab = "Overview",
  });

  @override
  Widget build(BuildContext context) {
    if (activeTab == "AI Usage") {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.smart_toy_rounded,
                    iconColor: const Color(0xFF10B981),
                    value: "24,180",
                    label: "AI Scans Completed",
                    badgeText: "+31%",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    value: "99.4%",
                    label: "OCR Accuracy",
                    badgeText: "+0.8%",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.memory_rounded,
                    iconColor: const Color(0xFF0052FF),
                    value: "4.8M",
                    label: "Tokens Processed",
                    badgeText: "+24%",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.speed_rounded,
                    iconColor: const Color(0xFF0D9488),
                    value: "420 ms",
                    label: "Avg Scan Speed",
                    badgeText: "-12% time",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (activeTab == "Storage") {
      return Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.sd_storage_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    value: "142 GB",
                    label: "Total Storage Used",
                    badgeText: "78% quota",
                    badgeColor: const Color(0xFFD97706),
                    badgeBg: const Color(0xFFFFFBEB),
                    hasAmberBorder: true,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.image_rounded,
                    iconColor: const Color(0xFF0052FF),
                    value: "98 GB",
                    label: "Card Media Assets",
                    badgeText: "+18%",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.picture_as_pdf_rounded,
                    iconColor: const Color(0xFFEF4444),
                    value: "34 GB",
                    label: "PDF Exports Data",
                    badgeText: "+12%",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.cloud_done_rounded,
                    iconColor: const Color(0xFF10B981),
                    value: "10 GB",
                    label: "System DB Backups",
                    badgeText: "100% synced",
                    badgeColor: const Color(0xFF10B981),
                    badgeBg: const Color(0xFFECFDF5),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Default Overview Tab
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.visibility_rounded,
                  iconColor: const Color(0xFF0052FF),
                  value: "892K",
                  label: "Total Card Views",
                  badgeText: "+14%",
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.business_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  value: "231",
                  label: "Active Companies",
                  badgeText: "+6%",
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.smart_toy_rounded,
                  iconColor: const Color(0xFF10B981),
                  value: "24,180",
                  label: "AI Scans Completed",
                  badgeText: "+31%",
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.sd_storage_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: "142 GB",
                  label: "Storage Used",
                  badgeText: "78% quota",
                  badgeColor: const Color(0xFFD97706),
                  badgeBg: const Color(0xFFFFFBEB),
                  hasAmberBorder: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    bool hasAmberBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(
            color: hasAmberBorder ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
            width: hasAmberBorder ? 3.5 : 1.2,
          ),
          top: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          right: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          bottom: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: hasAmberBorder
                ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasAmberBorder ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
