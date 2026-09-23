import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import '../../master_admin/notifications/widgets/notification_item_card.dart';

class MasterAdminTopNav extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? customRightAction;

  const MasterAdminTopNav({
    super.key,
    this.title,
    this.customRightAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    String currentPath = '/master-admin/dashboard';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {
      try {
        currentPath = GoRouter.of(context).routeInformationProvider.value.uri.path;
      } catch (_) {}
    }

    final isDashboard = currentPath == '/master-admin/dashboard' || currentPath == '/master-admin';
    final isCompanies = currentPath == '/master-admin/company';
    final isCompanyDetail = currentPath.startsWith('/master-admin/company/');
    final isApprovals = currentPath.startsWith('/master-admin/approval');
    final isIndividuals = currentPath.startsWith('/master-admin/individuals');
    final isLeads = currentPath.startsWith('/master-admin/leads');
    final isCampaigns = currentPath.startsWith('/master-admin/campaign');
    final isAnalytics = currentPath.startsWith('/master-admin/analytics');
    final isWorkspace = currentPath.startsWith('/master-admin/workspace');
    final isSettings = currentPath.startsWith('/master-admin/settings');
    final isProfile = currentPath.startsWith('/master-admin/profile');
    final isNotifications = currentPath.startsWith('/master-admin/notifications');

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
            GestureDetector(
              onTap: () {
                context.push('/master-admin/profile');
              },
              child: Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "MA",
                        style: AppFontStyle.titleMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: () {
                SmartBackHandler.handleMasterAdminBack(context: context);
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

          // CENTER TITLE + BADGE
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title ??
                        (isDashboard
                            ? "Platform Admin"
                            : isCompanies
                                ? "Companies"
                                : isCompanyDetail
                                    ? "Company Details"
                                    : isApprovals
                                        ? "Pending Approvals"
                                        : isIndividuals
                                            ? "Individuals"
                                            : isLeads
                                                ? "Platform Lead Audit Logs"
                                                : isCampaigns
                                                    ? "Global Campaigns"
                                                    : isAnalytics
                                                        ? "Platform Usage Analytics"
                                                        : isWorkspace
                                                            ? "Workspaces"
                                                            : isSettings
                                                                ? "Platform Settings"
                                                                : isProfile
                                                                    ? "Admin Profile"
                                                                    : isNotifications
                                                                        ? "Notifications"
                                                                        : "Master Admin"),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDashboard) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                    ),
                    child: const Text(
                      "SUPER ADMIN",
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // RIGHT ACTIONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customRightAction != null)
                customRightAction!
              else if (isProfile)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Admin profile changes saved successfully!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF0F172A),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                )
              else if (isNotifications)
                GestureDetector(
                  onTap: () {
                    NotificationStore.markAllAsRead();
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All notifications marked as read"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF0F172A),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(
                      "Mark all read",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                )
              else
                ValueListenableBuilder<bool>(
                  valueListenable: NotificationStore.hasUnreadNotifier,
                  builder: (context, hasUnread, _) {
                    return _buildIconButton(
                      icon: Icons.notifications_none_rounded,
                      showDot: hasUnread,
                      onTap: () {
                        context.push('/master-admin/notifications');
                      },
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    Color iconColor = const Color(0xFF0F172A),
    bool showDot = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),
          if (showDot)
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
