import 'package:flutter/material.dart';

class PricingPlansScreen extends StatelessWidget {
  const PricingPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pricing Plans')),
      body: const Center(
        child: Text('Pricing Plans Screen'),
      ),
    );
  }
}
