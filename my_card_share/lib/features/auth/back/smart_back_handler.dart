// smart_back_handler.dart
//
// Provides accurate mobile-style back navigation for the entire portal.
//
// BEHAVIOUR:
//  1. On any non-home tab (Vault / Scanner / Leads / Profile)
//     → go back to Home tab. Does NOT close the app.
//
//  2. On Home tab
//     → First press: show "Press back again to exit" snackbar.
//     → Second press within 2 s: exit the app.
//
// TAB RESET (clean UI when switching tabs):
//  • When the user switches tabs or presses back to Home, any open
//    dialogs / drawers / modals on the leaving tab are auto-popped.
//
// SWIPE-BACK GESTURE:
//  • [SmartPopScope] wraps each tab page and intercepts iOS/Android
//    edge-swipe AND hardware back, routing through [SmartBackHandler].
//
// SMOOTH TRANSITIONS:
//  • [SmoothPageRoute] is the polished slide+fade route to use for
//    all manual Navigator.push calls (e.g. Edit Profile).

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../individual/home/dashboard/dashboard_screen.dart';

// ---------------------------------------------------------------------------
// SmartBackHandler — core back-navigation logic
// ---------------------------------------------------------------------------

class SmartBackHandler {
  SmartBackHandler._();

  static DateTime? _lastBackPress;

  /// Call from PortalShell / PopScope when back is triggered on root page (Home).
  /// Returns true = event consumed.
  static bool handleRootBack({
    required BuildContext context,
  }) {
    // Rule 1: On Home with a sub-view open → close it first
    if (DashboardScreen.resetViewIfOpen()) {
      return true;
    }

    // Rule 2: On root page → double-back-to-exit pattern
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      _showExitSnackBar(context);
      return true;
    }

    // Second press within 2 s → exit
    SystemNavigator.pop();
    return true;
  }

  static void _showExitSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'Press back again to exit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SmartPopScope — wraps a tab page to intercept all back gestures
// ---------------------------------------------------------------------------

class SmartPopScope extends StatelessWidget {
  final Widget child;

  /// Called when user presses/swipes back on this page.
  /// Return true to indicate the event was handled.
  final bool Function() onBack;

  const SmartPopScope({
    super.key,
    required this.child,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false intercepts hardware back AND iOS/Android edge-swipe
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) onBack();
      },
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// SmoothPageRoute — polished slide-up + fade-in route for manual pushes
// (e.g. Navigator.of(context, rootNavigator: true).push(SmoothPageRoute(...)))
// ---------------------------------------------------------------------------

class SmoothPageRoute<T> extends CupertinoPageRoute<T> {
  SmoothPageRoute({required Widget page})
      : super(builder: (context) => page);
}
