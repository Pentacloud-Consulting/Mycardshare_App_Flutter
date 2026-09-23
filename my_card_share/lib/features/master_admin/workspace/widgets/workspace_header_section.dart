import 'package:flutter/material.dart';

class WorkspaceHeaderSection extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;

  const WorkspaceHeaderSection({
    super.key,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtext
        const Text(
          "Manage multi-tenant domains and workspace allocation",
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),

        // Rounded Search Bar
        Container(
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
              hintText: "Search workspaces...",
              hintStyle: TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
