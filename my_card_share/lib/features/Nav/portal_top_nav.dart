import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'profile_menu_list.dart';

class PortalTopNav extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? title;
  final String? subtitle;
  final Widget? customAction;
  final bool showBackButton;

  const PortalTopNav({
    super.key,
    this.userName = "Alex",
    this.title,
    this.subtitle,
    this.customAction,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  static const Map<String, Map<String, String>> _routeTitles = {
    '/portal': {'title': 'Home'},
    '/portal/vault': {'title': 'Contact Vault'},
    '/portal/profile': {'title': 'My Profile'},
    '/portal/scanner': {'title': 'Card & Voice Scanner'},
    '/portal/leads': {'title': 'Leads'},
    '/portal/analytics': {'title': 'Analytics & Insights'},
    '/portal/campaign': {'title': 'Campaigns'},
    '/portal/connectors': {'title': 'Integrations & Connectors'},
    '/portal/settings': {'title': 'Settings'},
    '/portal/subscription': {'title': 'MyCardShare Pro', 'subtitle': 'SUBSCRIPTION PLAN'},
    '/portal/notifications': {'title': 'Notifications'},
    '/portal/support/help': {'title': 'Help & Support'},
    '/portal/support/terms': {'title': 'Terms of Service'},
    '/portal/support/privacy': {'title': 'Privacy Policy'},
    '/portal/support/about': {'title': 'About MyCardShare'},
    '/portal/approvals': {'title': 'Approvals'},
    '/portal/companies': {'title': 'Companies'},
    '/portal/workforce': {'title': 'Workforce'},
  };

  String _deriveTitleFromPath(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return 'Home';
    final raw = segments.last;
    return raw
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  void _openMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Profile & Navigation",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const ProfileMenuList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentPath = '/portal';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
      } catch (_) {
        currentPath = '/portal';
      }
    }

    final bool isHome = currentPath == '/portal';

    final String resolvedTitle = title ??
        (_routeTitles[currentPath]?['title'] ?? _deriveTitleFromPath(currentPath));
    final String? resolvedSubtitle =
        subtitle ?? _routeTitles[currentPath]?['subtitle'];

    return SafeArea(
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFD),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Group: Hamburger Menu Button + Title or Greeting
            Row(
              children: [
                // Circular Light-Gray Menu Button (Image 2)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (showBackButton) {
                        Navigator.pop(context);
                      } else {
                        _openMenuModal(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showBackButton ? Icons.arrow_back_rounded : Icons.menu_rounded,
                        color: const Color(0xFF334155),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                if (isHome) ...[
                  // Greeting Text on Home: "Hi, Alex"
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        fontSize: 20,
                      ),
                      children: [
                        const TextSpan(
                          text: "Hi, ",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        TextSpan(
                          text: userName,
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Page Title & Subtitle on Sub-pages
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedTitle,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (resolvedSubtitle != null &&
                          resolvedSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          resolvedSubtitle.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),

            // Right Group: Custom Action + Bell Icon
            Row(
              children: [
                if (customAction != null) ...[
                  customAction!,
                  const SizedBox(width: 8),
                ],
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/portal/notifications'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF1E293B),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
