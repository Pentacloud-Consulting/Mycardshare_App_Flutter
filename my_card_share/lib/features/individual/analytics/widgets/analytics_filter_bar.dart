import 'package:flutter/material.dart';

class AnalyticsFilterBar extends StatelessWidget {
  final String selectedTab; // 'overview', 'leads', 'campaigns'
  final String dateRange;
  final ValueChanged<String> onTabChanged;
  final ValueChanged<String> onDateRangeChanged;

  const AnalyticsFilterBar({
    super.key,
    required this.selectedTab,
    required this.dateRange,
    required this.onTabChanged,
    required this.onDateRangeChanged,
  });

  void _showDateRangePicker(BuildContext context) {
    final options = ['Today', 'Last 7 Days', 'Last 30 Days', 'This Month', 'All Time'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Time Range",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...options.map((option) {
              final isSelected = option == dateRange;
              return ListTile(
                title: Text(
                  option,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF0F172A),
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0066FF), size: 20)
                    : null,
                onTap: () {
                  onDateRangeChanged(option);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Date Range Picker Row (Image 1 top right)
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDateRangePicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Color(0xFF334155),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Segmented Tabs Row: Overview | Leads | Campaigns
        Row(
          children: [
            Expanded(child: _buildTabButton("Overview", "overview")),
            const SizedBox(width: 8),
            Expanded(child: _buildTabButton("Leads", "leads")),
            const SizedBox(width: 8),
            Expanded(child: _buildTabButton("Campaigns", "campaigns")),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, String tabKey) {
    final isSelected = selectedTab == tabKey;
    return GestureDetector(
      onTap: () => onTabChanged(tabKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : Colors.white,
          borderRadius: BorderRadius.circular(22),
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
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
