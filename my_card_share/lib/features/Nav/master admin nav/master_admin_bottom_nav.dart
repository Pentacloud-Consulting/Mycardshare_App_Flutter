import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'master_admin_more_menu.dart';

class MasterAdminBottomNav extends StatefulWidget {
  const MasterAdminBottomNav({super.key});

  @override
  State<MasterAdminBottomNav> createState() => _MasterAdminBottomNavState();
}

class _MasterAdminBottomNavState extends State<MasterAdminBottomNav> {
  late final VoidCallback _routeListener;

  @override
  void initState() {
    super.initState();
    _routeListener = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      GoRouter.of(context).routerDelegate.removeListener(_routeListener);
      GoRouter.of(context).routerDelegate.addListener(_routeListener);
    } catch (_) {}
  }

  @override
  void dispose() {
    try {
      GoRouter.of(context).routerDelegate.removeListener(_routeListener);
    } catch (_) {}
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    String location = '/master-admin/dashboard';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        location = GoRouter.of(context).routeInformationProvider.value.uri.path;
      } catch (_) {
        location = '/master-admin/dashboard';
      }
    }

    if (location.startsWith('/master-admin/company')) return 1;
    if (location.startsWith('/master-admin/approval')) return 2;
    if (location.startsWith('/master-admin/individuals')) return 3;
    if (location.startsWith('/master-admin/leads') ||
        location.startsWith('/master-admin/campaign') ||
        location.startsWith('/master-admin/analytics') ||
        location.startsWith('/master-admin/workspace') ||
        location.startsWith('/master-admin/settings') ||
        location.startsWith('/master-admin/profile')) {
      return 4;
    }
    if (location.startsWith('/master-admin/dashboard') || location.startsWith('/master-admin')) {
      return 0;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 4) {
      // More tab tapped → open Master Admin Hub Bottom Sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const MasterAdminMoreMenu(),
      );
      return;
    }

    final targetLocation = switch (index) {
      0 => '/master-admin/dashboard',
      1 => '/master-admin/company',
      2 => '/master-admin/approval',
      3 => '/master-admin/individuals',
      _ => '/master-admin/dashboard',
    };

    final selectedIndex = _calculateSelectedIndex(context);
    if (selectedIndex == index && targetLocation != '/master-admin/dashboard') return;

    if (targetLocation == '/master-admin/dashboard') {
      while (context.canPop()) {
        context.pop();
      }
      context.go('/master-admin/dashboard');
    } else {
      context.go(targetLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Dashboard
              _buildNavItem(
                context: context,
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.bar_chart_rounded,
                label: 'Dashboard',
              ),

              // 2. Companies
              _buildNavItem(
                context: context,
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.business_rounded,
                label: 'Companies',
              ),

              // 3. Approvals (Center Raised Button with Pending Badge Count)
              GestureDetector(
                onTap: () => _onItemTapped(2, context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selectedIndex == 2 ? 1.06 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.fastOutSlowIn,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0052FF), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0052FF)
                                      .withValues(alpha: selectedIndex == 2 ? 0.45 : 0.28),
                                  blurRadius: selectedIndex == 2 ? 14 : 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                          ),
                          // Badge Count Overlay (Pending Approvals)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: const Text(
                                "5",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: selectedIndex == 2 ? FontWeight.w700 : FontWeight.w500,
                        color: selectedIndex == 2
                            ? const Color(0xFF0052FF)
                            : const Color(0xFF64748B),
                        letterSpacing: -0.1,
                      ),
                      child: const Text('Approvals'),
                    ),
                  ],
                ),
              ),

              // 4. Individuals
              _buildNavItem(
                context: context,
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.people_alt_rounded,
                label: 'Individuals',
              ),

              // 5. More (Profile Menu Hub)
              _buildNavItem(
                context: context,
                index: 4,
                selectedIndex: selectedIndex,
                icon: Icons.widgets_rounded,
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int selectedIndex,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;
    const activeColor = Color(0xFF0052FF);
    const inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(12),
      splashColor: activeColor.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
              child: Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 21,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: -0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
