import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class ProfileMenuList extends ConsumerWidget {
  const ProfileMenuList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role;
    final isEmployee = (role == 'employee');

    final menuItems = [
      _MenuItem(
        icon: Icons.analytics_outlined,
        title: 'Analytics',
        subtitle: 'Views, scans & lead insights',
        route: '/portal/analytics',
        color: const Color(0xFF0052FF),
      ),
      _MenuItem(
        icon: Icons.campaign_outlined,
        title: 'Campaign Tracking',
        subtitle: 'QR campaigns & analytics',
        route: '/portal/campaign',
        color: const Color(0xFF8B5CF6),
      ),
      _MenuItem(
        icon: Icons.extension_outlined,
        title: 'Connectors',
        subtitle: 'CRM & webhook integrations',
        route: '/portal/connectors',
        color: const Color(0xFF0D9488),
      ),
      _MenuItem(
        icon: Icons.settings_outlined,
        title: 'Account Settings',
        subtitle: 'Password, security & preferences',
        route: '/portal/settings',
        color: const Color(0xFF475569),
      ),
      if (isEmployee) ...[
        _MenuItem(
          icon: Icons.approval_outlined,
          title: 'Request Approvals',
          subtitle: 'Company card approval requests',
          route: '/portal/approvals',
          color: const Color(0xFFD97706),
          isEmployeeOnly: true,
        ),
        _MenuItem(
          icon: Icons.business_outlined,
          title: 'Associated Companies',
          subtitle: 'Workspaces & organization info',
          route: '/portal/companies',
          color: const Color(0xFF2563EB),
          isEmployeeOnly: true,
        ),
        _MenuItem(
          icon: Icons.badge_outlined,
          title: 'Team Workforce',
          subtitle: 'Team members & digital directories',
          route: '/portal/workforce',
          color: const Color(0xFF059669),
          isEmployeeOnly: true,
        ),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pro Upgrade / Status Banner Inside Menu
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            context.go('/portal/subscription');
          },
          child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text("👑", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Pro Subscription Active",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Unlimited cards, custom branding & analytics",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

        // Main Profile Menu Options
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: menuItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == menuItems.length - 1;


          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Row(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (item.isEmployeeOnly) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'EMPLOYEE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.route);
                },
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    ),
  ],
);
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final Color color;
  final bool isEmployeeOnly;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.color,
    this.isEmployeeOnly = false,
  });
}
