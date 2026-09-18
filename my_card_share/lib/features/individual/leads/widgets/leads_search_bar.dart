import 'package:flutter/material.dart';

class LeadsSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCalendarTap;

  const LeadsSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Input Box
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: "Search leads...",
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Color(0xFF64748B),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Calendar Date Filter Button
        GestureDetector(
          onTap: onCalendarTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Date range filter selected")),
                );
              },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF475569),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
