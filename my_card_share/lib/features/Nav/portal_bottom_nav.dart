import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../individual/home/dashboard/dashboard_screen.dart';

class PortalBottomNav extends StatefulWidget {
  const PortalBottomNav({super.key});

  @override
  State<PortalBottomNav> createState() => _PortalBottomNavState();
}

class _PortalBottomNavState extends State<PortalBottomNav> {
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
    String location = '/portal';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        location = GoRouter.of(context).routeInformationProvider.value.uri.path;
      } catch (_) {
        location = '/portal';
      }
    }

    if (location.startsWith('/portal/vault')) return 1;
    if (location.startsWith('/portal/scanner')) return 2;
    if (location.startsWith('/portal/leads')) return 3;
    if (location.startsWith('/portal/profile') ||
        location.startsWith('/portal/analytics') ||
        location.startsWith('/portal/campaign') ||
        location.startsWith('/portal/connectors') ||
        location.startsWith('/portal/settings') ||
        location.startsWith('/portal/approvals') ||
        location.startsWith('/portal/companies') ||
        location.startsWith('/portal/workforce')) {
      return 4;
    }
    if (location.startsWith('/portal')) return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final targetLocation = switch (index) {
      0 => '/portal',
      1 => '/portal/vault',
      2 => '/portal/scanner',
      3 => '/portal/leads',
      4 => '/portal/profile',
      _ => '/portal',
    };

    // Reset home sub-view when switching tabs
    DashboardScreen.resetToDefaultHome();

    if (targetLocation == '/portal') {
      while (context.canPop()) {
        context.pop();
      }
      context.go('/portal');
    } else {
      if (selectedIndex == index) return;
      context.push(targetLocation);
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
              _buildNavItem(
                context: context,
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_rounded,
                label: 'Home',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.folder_shared_rounded,
                label: 'Vault',
              ),
              // Center Raised Scan Button
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.fastOutSlowIn,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052FF).withValues(alpha: selectedIndex == 2 ? 0.45 : 0.25),
                              blurRadius: selectedIndex == 2 ? 14 : 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
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
                      child: const Text('Scan'),
                    ),
                  ],
                ),
              ),
              _buildNavItem(
                context: context,
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.people_alt_rounded,
                label: 'Leads',
              ),
              _buildNavItem(
                context: context,
                index: 4,
                selectedIndex: selectedIndex,
                icon: Icons.person_rounded,
                label: 'Profile',
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
