import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardStatsGrid extends StatelessWidget {
  final String totalCompanies;
  final String totalIndividuals;
  final String totalLeads;
  final String pendingApprovals;

  const DashboardStatsGrid({
    super.key,
    this.totalCompanies = "248",
    this.totalIndividuals = "12,847",
    this.totalLeads = "18,204",
    this.pendingApprovals = "6",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row: Total Companies & Total Individuals
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.business_rounded,
                  iconColor: const Color(0xFF0052FF),
                  value: totalCompanies,
                  label: "Total Companies",
                  badgeText: "+12 this month",
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                  route: '/master-admin/company',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  value: totalIndividuals,
                  label: "Total Individuals",
                  badgeText: "+340",
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                  route: '/master-admin/individuals',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Bottom Row: Platform Leads & 4th Box (Pending Approvals)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.assignment_rounded,
                  iconColor: const Color(0xFF0D9488),
                  value: totalLeads,
                  label: "Platform Leads",
                  badgeText: "+8%",
                  badgeColor: const Color(0xFF10B981),
                  badgeBg: const Color(0xFFECFDF5),
                  route: '/master-admin/leads',
                ),
              ),
              const SizedBox(width: 14),
              // 4TH BOX: PENDING APPROVALS
              Expanded(
                child: _buildStatCard(
                  context: context,
                  icon: Icons.verified_user_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  value: pendingApprovals,
                  label: "Pending Approvals",
                  badgeText: "6 pending",
                  badgeColor: const Color(0xFFD97706),
                  badgeBg: const Color(0xFFFFFBEB),
                  route: '/master-admin/approval',
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
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required String route,
    bool hasAmberBorder = false,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.14)
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
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
