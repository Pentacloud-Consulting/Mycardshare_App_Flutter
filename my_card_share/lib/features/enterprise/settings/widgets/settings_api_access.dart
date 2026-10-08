import 'package:flutter/material.dart';

/// Shows modern "Coming Soon" popup sheet for Developer REST API Access & Webhooks.
Future<void> showApiAccessComingSoonPopup(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon Badge
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.key_rounded,
              size: 30,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "API Access & Webhooks",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            "REST API keys, webhooks, and direct CRM integrations (HubSpot, Salesforce) will be available soon in the upcoming Developer Portal release.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Got it",
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
