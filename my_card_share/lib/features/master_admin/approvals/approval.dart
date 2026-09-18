import 'package:flutter/material.dart';

class MasterAdminApprovalScreen extends StatelessWidget {
  const MasterAdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Company Pending Approvals')),
      body: const Center(child: Text('Pending Approvals')),
    );
  }
}
