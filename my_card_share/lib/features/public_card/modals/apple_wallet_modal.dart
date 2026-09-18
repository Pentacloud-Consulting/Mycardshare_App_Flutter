import 'package:flutter/material.dart';

class AppleWalletModal extends StatelessWidget {
  const AppleWalletModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const AppleWalletModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Add to Apple Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Passbook / PKPass generation for Apple Wallet.'),
        ],
      ),
    );
  }
}
