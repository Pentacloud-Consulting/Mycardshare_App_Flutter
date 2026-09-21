import 'package:flutter/material.dart';

class SubscriptionHeroHeader extends StatelessWidget {
  final VoidCallback? onCloseTap;

  const SubscriptionHeroHeader({
    super.key,
    this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        // Glowing Crown Emblem with Sunburst Rays
        Stack(
          alignment: Alignment.center,
          children: [
            // Soft background glow
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFEF08A),
                    Color(0x00FEF08A),
                  ],
                ),
              ),
            ),

            // Outer ring
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFEF9C3), Color(0xFFFDE047)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33F59E0B),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFACC15), Color(0xFFEAB308)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Main Title
        const Text(
          "Unlock MyCardShare Pro",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // Subtitle
        const Text(
          "Stand out and track your reach",
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
