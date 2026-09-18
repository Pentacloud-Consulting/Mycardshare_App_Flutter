import 'package:flutter/material.dart';

class SocialActionLinksModal extends StatelessWidget {
  const SocialActionLinksModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const SocialActionLinksModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Social / Action Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Quick action links for WhatsApp, LinkedIn, Website, etc.'),
        ],
      ),
    );
  }
}
