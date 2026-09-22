import 'package:flutter/material.dart';

class CompanyDetailStatsGrid extends StatelessWidget {
  final int activeEmployees;
  final int maxEmployees;
  final String totalLeads;
  final String cardViews;
  final String planValue;

  const CompanyDetailStatsGrid({
    super.key,
    this.activeEmployees = 34,
    this.maxEmployees = 50,
    this.totalLeads = "312",
    this.cardViews = "8,420",
    this.planValue = "\$299/mo",
  });

  @override
  Widget build(BuildContext context) {
    final progress = (activeEmployees / maxEmployees).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.groups_rounded,
                label: "Employees",
                value: "$activeEmployees/$maxEmployees",
                progressBar: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0052FF)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTile(
                icon: Icons.assignment_rounded,
                label: "Total Leads",
                value: totalLeads,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                icon: Icons.visibility_rounded,
                label: "Card Views",
                value: cardViews,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTile(
                icon: Icons.monetization_on_rounded,
                label: "Plan Value",
                value: planValue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? progressBar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF64748B), size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          if (progressBar != null) ...[
            const SizedBox(height: 8),
            progressBar,
          ],
        ],
      ),
    );
  }
}
