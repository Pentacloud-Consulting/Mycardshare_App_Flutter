import 'package:flutter/material.dart';

class VaultFilterPills extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const VaultFilterPills({
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
            icon: Icons.groups_rounded,
          ),
          const SizedBox(width: 10),
          _buildPill(
            id: 'ocr',
            label: 'AI Scan',
            icon: Icons.crop_free_rounded,
          ),
          const SizedBox(width: 10),
          _buildPill(
            id: 'voice',
            label: 'Voice',
            icon: Icons.mic_none_rounded,
          ),
          const SizedBox(width: 10),
          _buildPill(
            id: 'manual',
            label: 'Manual',
            icon: Icons.edit_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedFilter.toLowerCase() == id.toLowerCase();

    return GestureDetector(
      onTap: () => onFilterSelected(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0052FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x200052FF) : const Color(0x06000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
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
