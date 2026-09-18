import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../features/Nav/portal_bottom_nav.dart';
import '../../features/Nav/portal_top_nav.dart';
import '../../features/individual/home/dashboard/dashboard_screen.dart';

/// PortalShell wraps all bottom-nav portal routes inside a single Scaffold.
///
/// Back navigation rules (accurate fix using WidgetsBindingObserver):
///  1. On any non-home tab (Vault/Scanner/Leads/Profile) → go to Home (/portal)
///  2. On Home with a sub-view open (e.g. "My Digital Card") → close the sub-view
///  3. On Home at root → "press again to exit" toast, second back exits app
class PortalShell extends StatefulWidget {
  final Widget child;

  const PortalShell({super.key, required this.child});

  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> with WidgetsBindingObserver {
  DateTime? _lastBackPress;
  late GoRouter _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router = GoRouter.of(context);
  }

  @override
  void initState() {
    super.initState();
    // Register as the back button handler — highest priority observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called by Android system back button / gesture BEFORE Flutter's default handler.
  /// Returning true = we consumed the event (app does NOT close or pop).
  @override
  Future<bool> didPopRoute() async {
    if (!mounted) return false;
    return _handleBack();
  }

  bool _handleBack() {
    if (!mounted) return false;

    // Get current GoRouter location
    final location =
        _router.routeInformationProvider.value.uri.path;

    // Rule 1: Not on Home tab → navigate to Home
    if (location != '/portal') {
      DashboardScreen.resetToDefaultHome();
      _router.go('/portal');
      return true; // consumed — do NOT close app
    }

    // Rule 2: On Home but a sub-view is open (e.g. "My Digital Card") → close it
    final wasHandled = DashboardScreen.resetViewIfOpen();
    if (wasHandled) return true;

    // Rule 3: On Home root — "tap again to exit" pattern
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
      return true; // consumed — do NOT close app yet
    }

    // Second back press within 2s → exit
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false ensures iOS swipe-back gesture is also intercepted
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
