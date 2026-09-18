import 'package:flutter/material.dart';

class NotificationFilterPills extends StatelessWidget {
  final String selectedFilter; // 'all', 'leads', 'scans', 'system'
  final ValueChanged<String> onFilterSelected;

  const NotificationFilterPills({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'label': 'All', 'id': 'all'},
      {'label': 'Leads', 'id': 'leads'},
      {'label': 'Scans', 'id': 'scans'},
      {'label': 'System', 'id': 'system'},
    ];

    return Row(
      children: filters.map((f) {
        final isSelected = selectedFilter == f['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => onFilterSelected(f['id']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0066FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x330066FF),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
