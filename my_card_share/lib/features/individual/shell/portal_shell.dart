import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../Nav/portal_bottom_nav.dart';
import '../../auth/back/smart_back_handler.dart';
import '../home/dashboard/dashboard_screen.dart';

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
  DateTime? _lastBackPress;

  Future<bool> _handleBackPress(BuildContext context) async {
    final location = GoRouterState.of(context).matchedLocation;

    // Rule 1: On Home with a sub-view open → close it first
    if (location == '/portal') {
      final wasHandled = DashboardScreen.resetViewIfOpen();
      if (wasHandled) return false;
    }

    // Rule 2: Pop to previous tab in history
    final prevTab = SmartBackHandler.popTab();
    if (prevTab != null) {
      DashboardScreen.resetToDefaultHome();
      context.go(prevTab);
      return false;
    }

    // Rule 3: Double-tap to exit from Home root
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    await SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    SmartBackHandler.recordTabVisit(location);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleBackPress(context);
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: const PortalBottomNav(),
      ),
    );
  }
}
