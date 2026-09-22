import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // 1. Review Approvals
              _buildActionChip(
                context: context,
                label: "Review Approvals",
                icon: Icons.check_circle_rounded,
                tintColor: const Color(0xFFF59E0B),
                badgeText: "6",
                route: '/master-admin/approval',
              ),
              const SizedBox(width: 10),

              // 2. Manage Companies
              _buildActionChip(
                context: context,
                label: "Manage Companies",
                icon: Icons.business_rounded,
                tintColor: const Color(0xFF0052FF),
                route: '/master-admin/company',
              ),
              const SizedBox(width: 10),

              // 3. View Individuals
              _buildActionChip(
                context: context,
                label: "View Individuals",
                icon: Icons.people_alt_rounded,
                tintColor: const Color(0xFF8B5CF6),
                route: '/master-admin/individuals',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color tintColor,
    String? badgeText,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tintColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tintColor, size: 17),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
