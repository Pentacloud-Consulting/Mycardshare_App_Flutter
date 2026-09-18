import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/Nav/portal_bottom_nav.dart';
import '../../features/Nav/portal_top_nav.dart';
import '../../features/auth/back/smart_back_handler.dart';
import '../../features/individual/home/dashboard/dashboard_screen.dart';

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
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }

  bool _handleBack() {
    return SmartBackHandler.handleBack(
      context: context,
      router: _router,
      onLeavingCurrentTab: () {
        // Close any sub-view open on the Home dashboard
        DashboardScreen.resetToDefaultHome();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false ensures iOS swipe-back AND Android back are intercepted
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: const PortalTopNav(),
        body: widget.child,
        bottomNavigationBar: const PortalBottomNav(),
      ),
    );
  }
}

