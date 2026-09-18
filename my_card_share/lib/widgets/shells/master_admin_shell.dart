import 'package:flutter/material.dart';

class MasterAdminShell extends StatelessWidget {
  final Widget child;

  const MasterAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}
