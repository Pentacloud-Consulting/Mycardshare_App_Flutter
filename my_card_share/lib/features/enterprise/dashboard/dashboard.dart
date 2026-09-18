import 'package:flutter/material.dart';

class EnterpriseDashboardScreen extends StatelessWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enterprise Dashboard')),
      body: const Center(child: Text('Enterprise Dashboard')),
    );
  }
}
