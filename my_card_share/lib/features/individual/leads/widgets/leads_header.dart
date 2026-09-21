import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeadsHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onExportTap;

  const LeadsHeader({
    super.key,
    this.onBackTap,
    this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: onBackTap ?? () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/portal');
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
        ),

        // Title: Leads
        const Text(
          "Leads",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),

        // Export/Download Button
        GestureDetector(
          onTap: onExportTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Exporting leads data...")),
            );
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
