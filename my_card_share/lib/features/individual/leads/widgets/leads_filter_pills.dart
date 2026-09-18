import 'package:flutter/material.dart';

class LeadsFilterPills extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const LeadsFilterPills({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPill(
            id: 'all',
            label: 'All',
            icon: Icons.list_rounded,
          ),
          const SizedBox(width: 8),
          _buildPill(
            id: 'new',
            label: 'New',
            dotColor: const Color(0xFF22C55E),
          ),
          const SizedBox(width: 8),
          _buildPill(
            id: 'contacted',
            label: 'Contacted',
            dotColor: const Color(0xFFEAB308),
          ),
          const SizedBox(width: 8),
          _buildPill(
            id: 'qualified',
            label: 'Qualified',
            dotColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 8),
          _buildPill(
            id: 'lost',
            label: 'Lost',
            dotColor: const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String id,
    required String label,
    IconData? icon,
    Color? dotColor,
  }) {
    final isSelected = selectedFilter.toLowerCase() == id.toLowerCase();

    return GestureDetector(
      onTap: () => onFilterSelected(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0052FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x1F0052FF) : const Color(0x05000000),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              const SizedBox(width: 4),
            ],
            if (dotColor != null) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
