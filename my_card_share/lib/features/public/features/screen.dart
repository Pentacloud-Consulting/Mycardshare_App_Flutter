import 'package:flutter/material.dart';

class PublicFeaturesScreen extends StatelessWidget {
  const PublicFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: const Center(child: Text('Features')),
    );
  }
}
