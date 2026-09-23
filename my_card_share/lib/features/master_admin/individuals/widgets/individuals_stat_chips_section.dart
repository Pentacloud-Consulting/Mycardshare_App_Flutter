import 'package:flutter/material.dart';

class IndividualsStatChipsSection extends StatelessWidget {
  final int totalCount;
  final int activeCount;
  final int deactivatedCount;

  const IndividualsStatChipsSection({
    super.key,
    this.totalCount = 12847,
    this.activeCount = 12203,
    this.deactivatedCount = 644,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Total Chip
          _buildStatChip(
            label: "Total",
            count: _formatNumber(totalCount),
            bgColor: const Color(0xFFEFF6FF), // Blue tint
            textColor: const Color(0xFF1D4ED8),
            borderColor: const Color(0xFFBFDBFE),
          ),
          const SizedBox(width: 8),

          // Active Chip
          _buildStatChip(
            label: "Active",
            count: _formatNumber(activeCount),
            bgColor: const Color(0xFFDCFCE7), // Green tint
            textColor: const Color(0xFF15803D),
            borderColor: const Color(0xFF86EFAC),
          ),
          const SizedBox(width: 8),

          // Deactivated Chip
          _buildStatChip(
            label: "Deactivated",
            count: _formatNumber(deactivatedCount),
            bgColor: const Color(0xFFFEE2E2), // Red tint
            textColor: const Color(0xFFB91C1C),
            borderColor: const Color(0xFFFCA5A5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String count,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
