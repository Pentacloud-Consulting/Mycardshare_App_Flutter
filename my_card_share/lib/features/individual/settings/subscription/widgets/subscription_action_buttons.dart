import 'package:flutter/material.dart';
import '../../../../../backend/Stripe  Payment & Subscription/subscription_sync_service.dart';

class SubscriptionActionButtons extends StatefulWidget {
  const SubscriptionActionButtons({super.key});

  @override
  State<SubscriptionActionButtons> createState() => _SubscriptionActionButtonsState();
}

class _SubscriptionActionButtonsState extends State<SubscriptionActionButtons> {
  bool _isProcessing = false;

  void _handleStartTrial() async {
    setState(() => _isProcessing = true);
    try {
      final success = await SubscriptionSyncService.startStripeUpgrade(
        plan: 'pro',
        cycle: 'yearly',
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 Pro Subscription Checkout Launched!"),
            backgroundColor: Color(0xFF16A34A),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Stripe checkout could not be opened. Please verify network."),
            backgroundColor: Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error launching subscription: $e"),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRestore() async {
    setState(() => _isProcessing = true);
    final status = await SubscriptionSyncService.fetchSubscriptionStatus();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final isPro = status['isPro'] == true;
    final plan = (status['plan'] ?? 'free').toString();

    if (isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🎉 Active ${plan.toUpperCase()} subscription restored!"),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No previous Pro subscription found for this account."),
          backgroundColor: Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary Start Pro Trial Button (Vibrant Blue Gradient)
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isProcessing ? null : _handleStartTrial,
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330066FF),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: _isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Start Pro Trial",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Free Trial Subtitle Caption
        const Text(
          "7-day free trial, cancel anytime",
          style: TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 18),

        // Restore Purchase Link
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GestureDetector(
                onTap: _handleRestore,
                child: const Text(
                  "Restore Purchase",
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
          ],
        ),
      ],
    );
  }
}


