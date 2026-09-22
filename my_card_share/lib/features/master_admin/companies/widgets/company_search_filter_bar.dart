import 'package:flutter/material.dart';

class CompanySearchFilterBar extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onFilterSelected;
  final bool initialFilterVisible;

  const CompanySearchFilterBar({
    super.key,
    this.selectedFilter = "All",
    this.onSearchChanged,
    this.onFilterSelected,
    this.initialFilterVisible = true,
  });

  @override
  State<CompanySearchFilterBar> createState() => _CompanySearchFilterBarState();
}

class _CompanySearchFilterBarState extends State<CompanySearchFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isFilterVisible;

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'color': null},
    {'label': 'Active', 'color': const Color(0xFF10B981)},
    {'label': 'Pending', 'color': const Color(0xFFF59E0B)},
    {'label': 'Suspended', 'color': const Color(0xFFEF4444)},
  ];

  @override
  void initState() {
    super.initState();
    _isFilterVisible = widget.initialFilterVisible;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _isFilterVisible = !_isFilterVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar + Filter Button Row
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: widget.onSearchChanged,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(
                    hintText: "Search companies...",
                    hintStyle: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Filter Toggle Button
            GestureDetector(
              onTap: _toggleFilter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isFilterVisible ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isFilterVisible ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
                    width: _isFilterVisible ? 1.5 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isFilterVisible
                          ? const Color(0xFF0052FF).withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: _isFilterVisible ? const Color(0xFF0052FF) : const Color(0xFF0F172A),
                  size: 20,
                ),
              ),
            ),
          ],
        ),

        // Smooth Expand/Collapse Animated Filter Chips Row
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isFilterVisible
              ? Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isFilterVisible ? 1.0 : 0.0,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((filter) {
                          final label = filter['label'] as String;
                          final dotColor = filter['color'] as Color?;
                          final isSelected = widget.selectedFilter == label;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (widget.onFilterSelected != null) {
                                  widget.onFilterSelected!(label);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF0052FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
                                    width: 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
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
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? Colors.white : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}
