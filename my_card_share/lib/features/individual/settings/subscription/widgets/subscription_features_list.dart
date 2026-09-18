import 'package:flutter/material.dart';

class SubscriptionFeaturesList extends StatelessWidget {
  const SubscriptionFeaturesList({super.key});

  final List<String> _features = const [
    "Unlimited Digital Cards",
    "AI Card Scanner",
    "Advanced Analytics Dashboard",
    "Unlimited Contact Vault",
    "Premium Templates",
    "Priority Support",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7.0),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF0066FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                feature,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
