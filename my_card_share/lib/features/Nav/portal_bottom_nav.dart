import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../individual/home/dashboard/dashboard_screen.dart';

class PortalBottomNav extends StatelessWidget {
  const PortalBottomNav({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
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
    final String currentLocation = GoRouterState.of(context).matchedLocation;
    final targetLocation = switch (index) {
      0 => '/portal',
      1 => '/portal/vault',
      2 => '/portal/scanner',
      3 => '/portal/leads',
      4 => '/portal/profile',
      _ => '/portal',
    };

    if (currentLocation == targetLocation) {
      if (targetLocation == '/portal') {
        DashboardScreen.resetToDefaultHome();
      }
      return;
    }

    // Always reset home sub-view when switching tabs
    DashboardScreen.resetToDefaultHome();
    // Use go() — the GoRouter-recommended approach for ShellRoute tab switching
    context.go(targetLocation);
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
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Scan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.w600,
                        color: selectedIndex == 2
                            ? const Color(0xFF0052FF)
                            : const Color(0xFF64748B),
                      ),
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
    final color =
        isSelected ? const Color(0xFF0052FF) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
