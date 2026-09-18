import 'package:flutter/material.dart';

class MasterAdminCompanyDetailScreen extends StatelessWidget {
  final String? companyId;

  const MasterAdminCompanyDetailScreen({super.key, this.companyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company Controller')),
      body: Center(child: Text('Company Detail ID: ${companyId ?? "N/A"}')),
    );
  }
}
