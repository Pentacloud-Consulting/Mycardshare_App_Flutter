import 'package:flutter/material.dart';

class IndividualsFilterChipsSection extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const IndividualsFilterChipsSection({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  static const List<String> _filters = [
    "All",
    "Free",
    "Pro",
    "Deactivated",
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              checkmarkColor: Colors.white, // Bright white checkmark tick icon
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter == "Pro") ...[
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                  ] else if (filter == "Deactivated") ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(filter),
              selectedColor: const Color(0xFF2563EB),
              backgroundColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              pressElevation: 0,
              side: BorderSide(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}
