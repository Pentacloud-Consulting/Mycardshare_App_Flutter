import 'package:flutter/material.dart';
import '../../features/Nav/master admin nav/master_admin_top_nav.dart';
import '../../features/Nav/master admin nav/master_admin_bottom_nav.dart';
import '../../features/auth/back/smart_back_handler.dart';
import '../../features/auth/font style/font_style.dart';

class MasterAdminShell extends StatelessWidget {
  final Widget child;

  const MasterAdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppFontStyle.preventSystemFontScaling(
      context,
      SmartPopScope(
        onBack: () => SmartBackHandler.handleMasterAdminBack(context: context),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          appBar: const MasterAdminTopNav(),
          body: child,
          bottomNavigationBar: const MasterAdminBottomNav(),
        ),
      ),
    );
  }
}
