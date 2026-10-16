import 'package:flutter/material.dart';

class NotificationFilterPills extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final Map<String, int>? counts;

  const NotificationFilterPills({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"id": "all", "label": "All", "count": counts?['all'] ?? 0},
      {"id": "unread", "label": "Unread", "count": counts?['unread'] ?? 0},
      {"id": "leads", "label": "Leads & CRM", "count": counts?['leads'] ?? 0},
      {"id": "team", "label": "Team Access", "count": counts?['team'] ?? 0},
      {"id": "security", "label": "Security", "count": counts?['security'] ?? 0},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((item) {
          final id = item["id"] as String;
          final label = item["label"] as String;
          final count = item["count"] as int;
          final isSelected = id == activeFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => onFilterChanged(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0052FF) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0052FF)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xFF0052FF).withValues(alpha: 0.25)
                          : const Color(0xFF0F172A).withValues(alpha: 0.03),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}


