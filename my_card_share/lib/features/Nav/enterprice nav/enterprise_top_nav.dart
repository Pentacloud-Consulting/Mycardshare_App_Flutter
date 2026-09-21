import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnterpriseTopNav extends StatelessWidget implements PreferredSizeWidget {
  const EnterpriseTopNav({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    String currentPath = '/enterprise/dashboard';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
      } catch (_) {}
    }

    final isDashboard = currentPath == '/enterprise/dashboard' || currentPath == '/enterprise';
    final isWorkspace = currentPath.startsWith('/enterprise/workspace');
    final isLeads = currentPath.startsWith('/enterprise/leads');
    final isCampaigns = currentPath.startsWith('/enterprise/campaign');
    final isAnalytics = currentPath.startsWith('/enterprise/analytics');
    final isConnectors = currentPath.startsWith('/enterprise/connectors');
    final isSettings = currentPath.startsWith('/enterprise/settings');
    final isNotifications = currentPath.startsWith('/enterprise/notifications');
    final isBrandProfile = currentPath.startsWith('/enterprise/brand-profile');
    final isProfile = currentPath.startsWith('/enterprise/profile');

    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16.0,
        right: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // LEFT ACTION / ICON
          if (isDashboard)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0052FF).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.business_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/enterprise/dashboard');
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A),
                  size: 16,
                ),
              ),
            ),

          const SizedBox(width: 12),

          // CENTER TITLE / BRAND NAME
          Expanded(
            child: Text(
              isDashboard
                  ? "Acme Realty Group"
                  : isWorkspace
                      ? "Workspace"
                      : isLeads
                          ? "Leads"
                          : isCampaigns
                              ? "Campaigns"
                              : isAnalytics
                                  ? "Analytics"
                                  : isConnectors
                                      ? "CRM Connectors"
                                      : isSettings
                                          ? "Settings"
                                          : isNotifications
                                              ? "Notifications"
                                              : isBrandProfile
                                                  ? "Brand Profile"
                                                  : isProfile
                                                      ? "Brand Profile & Hub"
                                                      : "Enterprise Admin",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // RIGHT ACTIONS (Page Action + Notification Bell Icon across all screens)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page-specific action buttons
              if (isBrandProfile) ...[
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Brand Profile saved! Workspace cards updated.",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (isLeads) ...[
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Exporting leads CSV report..."),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: const Icon(
                      Icons.ios_share_rounded,
                      color: Color(0xFF0052FF),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (isAnalytics) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, color: Color(0xFF0052FF), size: 13),
                      SizedBox(width: 5),
                      Text(
                        "Last 30d",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Notification Bell (present across Team, Leads, Campaigns, Dashboard, etc.)
              _buildNotificationBell(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/enterprise/notifications');
      },
      child: Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
