import 'package:flutter/material.dart';

class ApprovalsStatChipsSection extends StatelessWidget {
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;

  const ApprovalsStatChipsSection({
    super.key,
    this.pendingCount = 2,
    this.approvedCount = 8,
    this.rejectedCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Pending Stat Chip (Amber)
          _buildChip(
            count: pendingCount,
            label: "Pending",
            bgColor: const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFFDE68A),
            textColor: const Color(0xFFD97706),
            dotColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 10),

          // Approved Stat Chip (Green)
          _buildChip(
            count: approvedCount,
            label: "Approved",
            bgColor: const Color(0xFFECFDF5),
            borderColor: const Color(0xFFA7F3D0),
            textColor: const Color(0xFF059669),
            dotColor: const Color(0xFF10B981),
          ),
          const SizedBox(width: 10),

          // Rejected Stat Chip (Red)
          _buildChip(
            count: rejectedCount,
            label: "Rejected",
            bgColor: const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFFECACA),
            textColor: const Color(0xFFDC2626),
            dotColor: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required int count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color dotColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: dotColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            "$label ",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
