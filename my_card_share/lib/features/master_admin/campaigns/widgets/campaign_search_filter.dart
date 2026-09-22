import 'package:flutter/material.dart';

class CampaignSearchFilter extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onFilterSelected;
  final bool initialFilterVisible;

  const CampaignSearchFilter({
    super.key,
    this.selectedFilter = "All",
    this.onSearchChanged,
    this.onFilterSelected,
    this.initialFilterVisible = true,
  });

  @override
  State<CampaignSearchFilter> createState() => _CampaignSearchFilterState();
}

class _CampaignSearchFilterState extends State<CampaignSearchFilter> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isFilterVisible;

  final List<Map<String, dynamic>> _filters = [
    {'label': 'All', 'icon': null},
    {'label': 'By Company', 'icon': Icons.keyboard_arrow_down_rounded},
    {'label': 'Top Performing', 'icon': Icons.trending_up_rounded},
    {'label': 'Ending Soon', 'icon': Icons.schedule_rounded},
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
        // Search bar + Filter/Sort Icon Button Row
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
                    hintText: "Search campaigns, company...",
                    hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
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
                  Icons.sort_rounded,
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
                          final icon = filter['icon'] as IconData?;
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
                                    if (icon != null && !isSelected) ...[
                                      Icon(icon, size: 14, color: const Color(0xFF64748B)),
                                      const SizedBox(width: 5),
                                    ],
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? Colors.white : const Color(0xFF475569),
                                      ),
                                    ),
                                    if (icon == Icons.keyboard_arrow_down_rounded && isSelected) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.white),
                                    ],
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
