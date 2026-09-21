import 'package:flutter/material.dart';

class LeadsFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const LeadsFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {"label": "All", "dotColor": null, "hasChevron": false},
      {"label": "By Employee", "dotColor": null, "hasChevron": true},
      {"label": "New", "dotColor": const Color(0xFF10B981), "hasChevron": false},
      {"label": "CRM Synced", "dotColor": const Color(0xFF0052FF), "hasChevron": false},
      {"label": "Failed", "dotColor": const Color(0xFFEF4444), "hasChevron": false},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final label = f["label"] as String;
          final dotColor = f["dotColor"] as Color?;
          final hasChevron = f["hasChevron"] as bool;
          final isSelected = selectedFilter == label;

          return GestureDetector(
            onTap: () => onSelected(label),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0052FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0052FF).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != null && !isSelected) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  if (hasChevron) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
