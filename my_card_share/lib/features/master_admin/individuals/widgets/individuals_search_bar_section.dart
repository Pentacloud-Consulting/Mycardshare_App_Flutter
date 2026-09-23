import 'package:flutter/material.dart';

class IndividualsSearchBarSection extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool isFilterActive;

  const IndividualsSearchBarSection({
    super.key,
    this.onSearchChanged,
    this.onFilterTap,
    this.isFilterActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Bar Input
        Expanded(
          child: Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                hintText: "Search by name, email...",
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
        ),
        const SizedBox(width: 10),

        // Filter Button Icon
        GestureDetector(
          onTap: onFilterTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isFilterActive ? const Color(0xFFEFF6FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isFilterActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: isFilterActive ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isFilterActive
                      ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                      : const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              color: isFilterActive ? const Color(0xFF2563EB) : const Color(0xFF475569),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
