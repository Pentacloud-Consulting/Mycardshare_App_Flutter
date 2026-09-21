import 'package:flutter/material.dart';

class LeadsStatsRow extends StatelessWidget {
  final int totalCount;
  final int thisWeekCount;
  final int syncFailedCount;

  const LeadsStatsRow({
    super.key,
    this.totalCount = 312,
    this.thisWeekCount = 28,
    this.syncFailedCount = 2,
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
          label: "This Week",
          value: "$thisWeekCount",
          bgColor: const Color(0xFFDCFCE7),
          borderColor: const Color(0xFFA7F3D0),
          textColor: const Color(0xFF10B981),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          label: "Sync Failed",
          value: "$syncFailedCount",
          bgColor: const Color(0xFFFEE2E2),
          borderColor: const Color(0xFFFECACA),
          textColor: const Color(0xFFEF4444),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
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
