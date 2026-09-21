import 'package:flutter/material.dart';
import '../../features/Nav/portal_bottom_nav.dart';
import '../../features/Nav/portal_top_nav.dart';
import '../../features/auth/back/smart_back_handler.dart';

/// PortalShell — wraps all bottom-nav portal routes inside a single Scaffold.
///
/// Back navigation is fully delegated to [SmartBackHandler]:
///  1. On any non-Home tab → go to Home (never close the app).
///  2. On Home → "press again to exit" toast, second press exits app.
///  3. Any open dialogs/modals on the leaving tab are auto-closed.
class PortalShell extends StatefulWidget {
  final Widget child;

  const PortalShell({super.key, required this.child});

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
        appBar: const PortalTopNav(),
        body: widget.child,
        bottomNavigationBar: const PortalBottomNav(),
      ),
    );
  }
}

