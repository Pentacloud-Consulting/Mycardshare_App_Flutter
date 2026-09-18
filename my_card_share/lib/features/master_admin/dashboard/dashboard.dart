import 'package:flutter/material.dart';

class MasterAdminDashboardScreen extends StatelessWidget {
  const MasterAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Admin Dashboard')),
      body: const Center(child: Text('Master Admin Dashboard')),
    );
  }
}
