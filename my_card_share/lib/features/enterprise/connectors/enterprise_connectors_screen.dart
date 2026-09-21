import 'package:flutter/material.dart';

import 'widgets/connector_cards_list.dart';
import 'widgets/connector_webhook_card.dart';
import 'widgets/connector_failed_sync_warning.dart';

class EnterpriseConnectorsScreen extends StatefulWidget {
  const EnterpriseConnectorsScreen({super.key});

  @override
  State<EnterpriseConnectorsScreen> createState() => _EnterpriseConnectorsScreenState();
}

class _EnterpriseConnectorsScreenState extends State<EnterpriseConnectorsScreen> {
  void _handleConnectTap(String crmName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Initiating OAuth connection for $crmName..."),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Top-Right Soft Baby-Blue Gradient Blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.18),
                    const Color(0xFF0052FF).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtext Header below app bar
                  const Text(
                    "Automatically sync leads to your CRM",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 1. CRM Integration Cards List (Salesforce, HubSpot, Zapier, Follow Up Boss)
                  ConnectorCardsList(
                    onConnectTap: _handleConnectTap,
                  ),

                  const SizedBox(height: 16),

                  // 2. Custom Webhook URL Card
                  const ConnectorWebhookCard(
                    webhookUrl: "https://hooks.zapier.com/hooks/catch/94021/b29x81a",
                  ),

                  const SizedBox(height: 16),

                  // 3. Failed Syncs Warning Card
                  const ConnectorFailedSyncWarning(
                    failedCount: 2,
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
