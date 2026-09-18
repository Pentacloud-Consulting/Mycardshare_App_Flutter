import 'package:flutter/material.dart';

class VcfSavingModal extends StatelessWidget {
  const VcfSavingModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const VcfSavingModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Contact / VCF Saving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Download VCF file directly into device contacts.'),
        ],
      ),
    );
  }
}
