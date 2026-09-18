import 'package:flutter/material.dart';

class QRCodeModal extends StatelessWidget {
  const QRCodeModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const QRCodeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('QR Code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Icon(Icons.qr_code_2, size: 120, color: Colors.blue),
        ],
      ),
    );
  }
}
