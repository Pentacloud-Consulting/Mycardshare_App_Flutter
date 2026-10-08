import 'package:flutter/material.dart';
import '../subscription/subscription_screen.dart';
import 'settings_billing_history.dart';
import 'settings_payment_method.dart';

class SettingsBillingCard extends StatelessWidget {
  final VoidCallback? onSubscriptionPlanTap;
  final VoidCallback? onBillingHistoryTap;
  final VoidCallback? onPaymentMethodTap;

  const SettingsBillingCard({
    super.key,
    this.onSubscriptionPlanTap,
    this.onBillingHistoryTap,
    this.onPaymentMethodTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "BILLING",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Subscription Plan with "Enterprise Pro" small blue badge tag (Image 1 style)
              InkWell(
                onTap: onSubscriptionPlanTap ??
                    () => Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (ctx) => const SubscriptionScreen()),
                        ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFD97706),
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Subscription Plan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
                        ),
                        child: const Text(
                          "Enterprise Pro",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 2: Billing History (Image 2 style)
              SettingsBillingHistoryRow(
                onTap: onBillingHistoryTap ?? () => showBillingHistoryPage(context),
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Row 3: Payment Method (Streamed real payment method)
              SettingsPaymentMethodRow(
                onTap: onPaymentMethodTap ?? () => showPaymentMethodPage(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


