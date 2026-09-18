import 'package:flutter/material.dart';

class SubscriptionPricingCard extends StatelessWidget {
  final bool isAnnual;

  const SubscriptionPricingCard({
    super.key,
    required this.isAnnual,
  });

  @override
  Widget build(BuildContext context) {
    final priceStr = isAnnual ? "\$9" : "\$12";
    final subtext = isAnnual ? "billed annually at \$86.40" : "billed monthly at \$12.00";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF0066FF), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120066FF),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    priceStr,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "/month",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Top Right Popular Badge (Image 1)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x202563EB),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "POPULAR",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
