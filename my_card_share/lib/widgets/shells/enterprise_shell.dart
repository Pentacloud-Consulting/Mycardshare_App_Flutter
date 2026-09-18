import 'package:flutter/material.dart';

class EnterpriseShell extends StatelessWidget {
  final Widget child;

  const EnterpriseShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
    );
  }
}
