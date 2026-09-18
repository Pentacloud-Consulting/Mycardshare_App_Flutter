import 'package:flutter/material.dart';

class SubscriptionBillingToggle extends StatelessWidget {
  final bool isAnnual;
  final ValueChanged<bool> onToggle;

  const SubscriptionBillingToggle({
    super.key,
    required this.isAnnual,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          // Monthly Option
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isAnnual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: !isAnnual
                      ? const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  "Monthly",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: !isAnnual ? FontWeight.bold : FontWeight.w600,
                    color: !isAnnual ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),

          // Annual Option (with Save 20% badge)
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isAnnual ? const Color(0xFF0066FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isAnnual
                      ? const [
                          BoxShadow(
                            color: Color(0x330066FF),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Annual",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: isAnnual ? FontWeight.bold : FontWeight.w600,
                        color: isAnnual ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAnnual ? const Color(0xFFDCFCE7) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Save 20%",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
