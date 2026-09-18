import 'package:flutter/material.dart';

class GoogleWalletModal extends StatelessWidget {
  const GoogleWalletModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const GoogleWalletModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Add to Google Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Google Pay / Wallet JWT pass integration.'),
        ],
      ),
    );
  }
}
