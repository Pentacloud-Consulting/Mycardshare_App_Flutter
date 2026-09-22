import 'package:flutter/material.dart';

class LeadAuditStatsRow extends StatelessWidget {
  final String totalCount;
  final String deliveredCount;
  final String failedCount;
  final String selectedFilter;
  final ValueChanged<String>? onFilterSelected;

  const LeadAuditStatsRow({
    super.key,
    this.totalCount = "18,204",
    this.deliveredCount = "17,890",
    this.failedCount = "314",
    this.selectedFilter = "All",
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            label: "Total",
            count: totalCount,
            filterKey: "All",
            bgColor: const Color(0xFFEFF6FF),
            textColor: const Color(0xFF0052FF),
            borderColor: const Color(0xFFBFDBFE),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            label: "Delivered",
            count: deliveredCount,
            filterKey: "Delivered",
            bgColor: const Color(0xFFECFDF5),
            textColor: const Color(0xFF10B981),
            borderColor: const Color(0xFFA7F3D0),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip(
            label: "Failed",
            count: failedCount,
            filterKey: "Failed",
            bgColor: const Color(0xFFFEF2F2),
            textColor: const Color(0xFFEF4444),
            borderColor: const Color(0xFFFECACA),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required String label,
    required String count,
    required String filterKey,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
  }) {
    final isSelected = selectedFilter == filterKey;

    return GestureDetector(
      onTap: () {
        if (onFilterSelected != null) {
          onFilterSelected!(filterKey);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? textColor.withValues(alpha: 0.15) : bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? textColor : borderColor,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: textColor.withValues(alpha: 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
