import 'package:flutter/material.dart';

class ExchangeContactModal extends StatelessWidget {
  const ExchangeContactModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const ExchangeContactModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Exchange Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Share your contact details back with the card owner.'),
        ],
      ),
    );
  }
}
