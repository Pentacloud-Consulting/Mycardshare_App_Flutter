import 'package:flutter/material.dart';

class WorkforceSearchAndFiltersSection extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final String selectedFilter;
  final ValueChanged<String>? onFilterSelected;

  const WorkforceSearchAndFiltersSection({
    super.key,
    this.onSearchChanged,
    this.selectedFilter = "All",
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              icon: Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              hintText: "Search teammates...",
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filter Chips Row: All, Admins, My Department
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ["All", "Admins", "My Department"].map((chip) {
              final isSelected = selectedFilter == chip;
              return GestureDetector(
                onTap: () => onFilterSelected?.call(chip),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7.5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0052FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0052FF).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    chip,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
