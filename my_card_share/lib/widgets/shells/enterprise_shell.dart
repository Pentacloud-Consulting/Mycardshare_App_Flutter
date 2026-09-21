import 'package:flutter/material.dart';
import '../../features/Nav/enterprice nav/enterprise_top_nav.dart';
import '../../features/Nav/enterprice nav/enterprise_bottom_nav.dart';
import '../../features/auth/back/smart_back_handler.dart';

class EnterpriseShell extends StatelessWidget {
  final Widget child;

  const EnterpriseShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          SmartBackHandler.handleEnterpriseBack(context: context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFD),
        appBar: const EnterpriseTopNav(),
        body: child,
        bottomNavigationBar: const EnterpriseBottomNav(),
      ),
    );
  }
}
