import 'package:flutter/material.dart';

class CompanyBrandingCardSection extends StatelessWidget {
  final Color lockedColor;
  final String lockedColorName;

  const CompanyBrandingCardSection({
    super.key,
    this.lockedColor = const Color(0xFF0052FF),
    this.lockedColorName = "Corporate Blue (#0052FF)",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Card Branding",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0052FF).withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Color(0xFF0052FF),
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Brand color locked by admin",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),

                  // Small Color Swatch Circle
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: lockedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Company logo & corporate banner applied automatically to your digital card.",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
