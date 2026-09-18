import 'package:flutter/material.dart';
import 'widgets/subscription_action_buttons.dart';
import 'widgets/subscription_billing_toggle.dart';
import 'widgets/subscription_features_list.dart';
import 'widgets/subscription_hero_header.dart';
import 'widgets/subscription_pricing_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isAnnual = true; // Annual selected by default matching Image 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            children: [
              // Hero Header with Close X, Crown Badge, Title & Subtitle
              SubscriptionHeroHeader(
                onCloseTap: () => Navigator.maybePop(context),
              ),

              const SizedBox(height: 24),

              // Monthly vs Annual Toggle (with Save 20% badge)
              SubscriptionBillingToggle(
                isAnnual: _isAnnual,
                onToggle: (val) => setState(() => _isAnnual = val),
              ),

              const SizedBox(height: 24),

              // Features Checklist
              const SubscriptionFeaturesList(),

              const SizedBox(height: 24),

              // Pricing Plan Card with Popular Badge
              SubscriptionPricingCard(isAnnual: _isAnnual),

              const SizedBox(height: 24),

              // Action Buttons (Start Pro Trial + Free trial caption + Restore purchase)
              const SubscriptionActionButtons(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
