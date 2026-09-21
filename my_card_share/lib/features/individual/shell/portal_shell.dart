import 'package:flutter/material.dart';
import '../../Nav/portal_bottom_nav.dart';
import '../../auth/back/smart_back_handler.dart';

class PortalShell extends StatefulWidget {
  final Widget child;

  const PortalShell({
    super.key,
    required this.child,
  });

  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          SmartBackHandler.handleRootBack(context: context);
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: const PortalBottomNav(),
      ),
    );
  }
}
