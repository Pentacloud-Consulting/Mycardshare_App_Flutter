import 'package:flutter/material.dart';

class LeadsSearchFilter extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCalendarTap;
  final bool isDateFiltered;

  const LeadsSearchFilter({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCalendarTap,
    this.isDateFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Rounded White Search Bar
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: "Search leads, employee...",
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Small Calendar / Date Filter Icon Button
        GestureDetector(
          onTap: onCalendarTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDateFiltered ? const Color(0xFF0052FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDateFiltered ? const Color(0xFF0052FF) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDateFiltered
                      ? const Color(0xFF0052FF).withValues(alpha: 0.25)
                      : const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Center(
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: isDateFiltered ? Colors.white : const Color(0xFF0052FF),
                      size: 19,
                    ),
                  ),
                  if (isDateFiltered)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38BDF8),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


