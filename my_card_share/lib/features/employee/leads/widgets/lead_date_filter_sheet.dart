import 'package:flutter/material.dart';

enum LeadDatePreset {
  allTime,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  custom,
}

class LeadDateFilterResult {
  final LeadDatePreset preset;
  final DateTimeRange? customRange;

  const LeadDateFilterResult({
    required this.preset,
    this.customRange,
  });

  bool matches(DateTime date) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    switch (preset) {
      case LeadDatePreset.allTime:
        return true;
      case LeadDatePreset.today:
        return date.isAfter(todayStart) && date.isBefore(tomorrowStart);
      case LeadDatePreset.yesterday:
        final yesterdayStart = todayStart.subtract(const Duration(days: 1));
        return date.isAfter(yesterdayStart) && date.isBefore(todayStart);
      case LeadDatePreset.thisWeek:
        final weekStart = todayStart.subtract(Duration(days: todayStart.weekday - 1));
        return date.isAfter(weekStart);
      case LeadDatePreset.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return date.isAfter(monthStart);
      case LeadDatePreset.custom:
        if (customRange == null) return true;
        final start = DateTime(customRange!.start.year, customRange!.start.month, customRange!.start.day);
        final end = DateTime(customRange!.end.year, customRange!.end.month, customRange!.end.day, 23, 59, 59);
        return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end));
    }
  }

  String get label {
    switch (preset) {
      case LeadDatePreset.allTime:
        return 'All Time';
      case LeadDatePreset.today:
        return 'Today';
      case LeadDatePreset.yesterday:
        return 'Yesterday';
      case LeadDatePreset.thisWeek:
        return 'This Week';
      case LeadDatePreset.thisMonth:
        return 'This Month';
      case LeadDatePreset.custom:
        if (customRange == null) return 'Custom Range';
        return '${customRange!.start.day}/${customRange!.start.month} - ${customRange!.end.day}/${customRange!.end.month}';
    }
  }
}

/// Real Date Range Picker Modal Sheet for Employee Leads
class LeadDateFilterSheet extends StatefulWidget {
  final LeadDateFilterResult currentFilter;

  const LeadDateFilterSheet({
    super.key,
    required this.currentFilter,
  });

  static Future<LeadDateFilterResult?> show(
    BuildContext context, {
    required LeadDateFilterResult currentFilter,
  }) {
    return showModalBottomSheet<LeadDateFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeadDateFilterSheet(currentFilter: currentFilter),
    );
  }

  @override
  State<LeadDateFilterSheet> createState() => _LeadDateFilterSheetState();
}

class _LeadDateFilterSheetState extends State<LeadDateFilterSheet> {
  late LeadDatePreset _selectedPreset;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.currentFilter.preset;
    _customRange = widget.currentFilter.customRange;
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0052FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = LeadDatePreset.custom;
        _customRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Title & Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF0052FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Filter by Date",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedPreset = LeadDatePreset.allTime;
                    _customRange = null;
                  });
                },
                child: const Text(
                  "Reset",
                  style: TextStyle(color: Color(0xFF0052FF), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Preset Options List
          _buildPresetTile(
            title: "All Time",
            subtitle: "Show all captured leads without date restriction",
            preset: LeadDatePreset.allTime,
            icon: Icons.all_inclusive_rounded,
          ),
          _buildPresetTile(
            title: "Today",
            subtitle: "Leads captured since midnight today",
            preset: LeadDatePreset.today,
            icon: Icons.today_rounded,
          ),
          _buildPresetTile(
            title: "Yesterday",
            subtitle: "Leads captured during previous day",
            preset: LeadDatePreset.yesterday,
            icon: Icons.history_rounded,
          ),
          _buildPresetTile(
            title: "This Week",
            subtitle: "Leads captured from Monday to now",
            preset: LeadDatePreset.thisWeek,
            icon: Icons.date_range_rounded,
          ),
          _buildPresetTile(
            title: "This Month",
            subtitle: "Leads captured in current calendar month",
            preset: LeadDatePreset.thisMonth,
            icon: Icons.calendar_view_month_rounded,
          ),

          // Custom Date Range Option
          InkWell(
            onTap: _pickCustomDateRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedPreset == LeadDatePreset.custom
                    ? const Color(0xFF0052FF).withValues(alpha: 0.06)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedPreset == LeadDatePreset.custom
                      ? const Color(0xFF0052FF)
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_calendar_rounded,
                    color: _selectedPreset == LeadDatePreset.custom
                        ? const Color(0xFF0052FF)
                        : const Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Custom Date Range",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _customRange != null
                              ? "${_customRange!.start.day}/${_customRange!.start.month}/${_customRange!.start.year} - ${_customRange!.end.day}/${_customRange!.end.month}/${_customRange!.end.year}"
                              : "Pick starting and ending dates",
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedPreset == LeadDatePreset.custom)
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF0052FF), size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final result = LeadDateFilterResult(
                  preset: _selectedPreset,
                  customRange: _customRange,
                );
                Navigator.pop(context, result);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                "Apply Date Filter",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTile({
    required String title,
    required String subtitle,
    required LeadDatePreset preset,
    required IconData icon,
  }) {
    final isSelected = _selectedPreset == preset;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPreset = preset;
          if (preset != LeadDatePreset.custom) {
            _customRange = null;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0052FF).withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0052FF) : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF0052FF) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF0052FF), size: 20),
          ],
        ),
      ),
    );
  }
}
