import 'package:flutter/material.dart';

class WorkspaceStatsRow extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int pendingCount;

  const WorkspaceStatsRow({
    super.key,
    this.totalCount = 34,
    this.activeCount = 31,
    this.pendingCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatChip(
          label: "Total",
          value: "$totalCount",
          bgColor: const Color(0xFFEFF4FF),
          borderColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF0052FF),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          label: "Active",
          value: "$activeCount",
          bgColor: const Color(0xFFDCFCE7),
          borderColor: const Color(0xFFA7F3D0),
          textColor: const Color(0xFF10B981),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          label: "Pending",
          value: "$pendingCount",
          bgColor: const Color(0xFFFEF3C7),
          borderColor: const Color(0xFFFDE68A),
          textColor: const Color(0xFFD97706),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
