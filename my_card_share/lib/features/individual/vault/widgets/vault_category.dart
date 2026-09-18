import 'package:flutter/material.dart';

class VaultCategory extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const VaultCategory({
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
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 4),
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
