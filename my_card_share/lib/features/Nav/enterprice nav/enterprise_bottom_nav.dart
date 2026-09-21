import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnterpriseBottomNav extends StatefulWidget {
  const EnterpriseBottomNav({super.key});

  @override
  State<EnterpriseBottomNav> createState() => _EnterpriseBottomNavState();
}

class _EnterpriseBottomNavState extends State<EnterpriseBottomNav> {
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
    String location = '/enterprise/dashboard';
    try {
      location = GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        location = GoRouter.of(context).routeInformationProvider.value.uri.path;
      } catch (_) {
        location = '/enterprise/dashboard';
      }
    }

    if (location.startsWith('/enterprise/workspace')) return 1;
    if (location.startsWith('/enterprise/leads')) return 2;
    if (location.startsWith('/enterprise/campaign')) return 3;
    if (location.startsWith('/enterprise/profile') ||
        location.startsWith('/enterprise/brand-profile') ||
        location.startsWith('/enterprise/analytics') ||
        location.startsWith('/enterprise/connectors') ||
        location.startsWith('/enterprise/settings')) {
      return 4;
    }
    if (location.startsWith('/enterprise/dashboard') || location == '/enterprise') return 0;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final targetLocation = switch (index) {
      0 => '/enterprise/dashboard',
      1 => '/enterprise/workspace',
      2 => '/enterprise/leads',
      3 => '/enterprise/campaign',
      4 => '/enterprise/profile',
      _ => '/enterprise/dashboard',
    };

    context.go(targetLocation);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.space_dashboard_rounded, "Dashboard", selectedIndex),
          _buildNavItem(1, Icons.groups_outlined, "Team", selectedIndex),
          _buildNavItem(2, Icons.assignment_outlined, "Leads", selectedIndex),
          _buildNavItem(3, Icons.campaign_outlined, "Campaigns", selectedIndex),
          _buildNavItem(4, Icons.person_outline_rounded, "Profile", selectedIndex),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, int selectedIndex) {
    final isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF0052FF) : const Color(0xFF64748B),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF0052FF) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
