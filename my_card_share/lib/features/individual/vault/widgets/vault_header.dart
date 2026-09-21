import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaultHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onFilterTap;

  const VaultHeader({
    super.key,
    this.onBackTap,
    this.onFilterTap,
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

        // Title: Contact Vault
        const Text(
          "Contact Vault",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),

        // Filter Action Button
        GestureDetector(
          onTap: onFilterTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Filter options opened")),
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
              Icons.tune_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
