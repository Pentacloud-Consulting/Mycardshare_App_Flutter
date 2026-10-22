import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../backend/employee_join/notification/app_notification_service.dart';
import 'widgets/notification_filter_pills.dart';
import 'widgets/notification_list_tile.dart';
import 'widgets/notification_section_header.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    });
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    AppNotificationService.instance.fetchNotifications(uid);
  }

  void _markAllRead() {
    ScaffoldMessenger.of(context).clearSnackBars();
    AppNotificationService.instance.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications marked as read!"),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _clearAllNotifications() {
    ScaffoldMessenger.of(context).clearSnackBars();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    AppNotificationService.instance.clearAllNotifications(targetUid: uid);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications cleared"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void _deleteNotification(String id) {
    ScaffoldMessenger.of(context).clearSnackBars();
    AppNotificationService.instance.deleteNotification(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Notification deleted"),
        duration: Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleNotificationTap(AppNotificationItem n) {
    ScaffoldMessenger.of(context).clearSnackBars();
    AppNotificationService.instance.markAsRead(n.id);

    String targetRoute = n.route ?? '';
    if (targetRoute.isEmpty) {
      final cat = n.category.toLowerCase();
      final title = n.title.toLowerCase();
      if (cat == 'leads' || title.contains('lead')) {
        targetRoute = '/portal/leads';
      } else if (cat == 'scans' || title.contains('scan') || title.contains('view')) {
        targetRoute = '/portal/analytics';
      } else if (title.contains('vault') || title.contains('contact')) {
        targetRoute = '/portal/vault';
      } else if (title.contains('password') || title.contains('security') || cat == 'system') {
        targetRoute = '/portal/settings';
      } else {
        targetRoute = '/portal';
      }
    }

    try {
      context.go(targetRoute);
    } catch (_) {
      try {
        context.push(targetRoute);
      } catch (e) {
        debugPrint('[NotificationScreen] Navigation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppNotificationService.instance,
      builder: (context, _) {
        final notifications = AppNotificationService.instance.notifications;

        final filteredList = notifications.where((n) {
          if (_selectedFilter == 'all') return true;
          return n.category.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();

        final todayItems = filteredList.where((n) => n.section == 'TODAY').toList();
        final yesterdayItems = filteredList.where((n) => n.section == 'YESTERDAY').toList();
        final earlierItems = filteredList.where((n) => n.section == 'EARLIER').toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFD),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Action Row (Recent Notifications | Clear all | Mark all read)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Recent Notifications",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (notifications.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: _clearAllNotifications,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Clear all",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _markAllRead,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "Mark all read",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category Filter Pills (All | Leads | Scans | System)
                  NotificationFilterPills(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) => setState(() => _selectedFilter = filter),
                  ),
                  const SizedBox(height: 16),

                  // Empty State (Zero notifications)
                  if (filteredList.isEmpty) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0052FF).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              size: 44,
                              color: Color(0xFF0052FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No notifications yet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "You'll see real updates here when your card is scanned,\nleads are captured, or settings change.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // TODAY Section
                  if (todayItems.isNotEmpty) ...[
                    const NotificationSectionHeader(title: "TODAY"),
                    ...todayItems.map((n) => NotificationListTile(
                          id: n.id,
                          title: n.title,
                          subtitle: n.subtitle,
                          time: n.time,
                          icon: n.icon,
                          iconBg: n.iconBg,
                          iconColor: n.iconColor,
                          isUnread: n.isUnread,
                          onTap: () => _handleNotificationTap(n),
                          onDelete: () => _deleteNotification(n.id),
                        )),
                  ],

                  // YESTERDAY Section
                  if (yesterdayItems.isNotEmpty) ...[
                    const NotificationSectionHeader(title: "YESTERDAY"),
                    ...yesterdayItems.map((n) => NotificationListTile(
                          id: n.id,
                          title: n.title,
                          subtitle: n.subtitle,
                          time: n.time,
                          icon: n.icon,
                          iconBg: n.iconBg,
                          iconColor: n.iconColor,
                          isUnread: n.isUnread,
                          onTap: () => _handleNotificationTap(n),
                          onDelete: () => _deleteNotification(n.id),
                        )),
                  ],

                  // EARLIER Section
                  if (earlierItems.isNotEmpty) ...[
                    const NotificationSectionHeader(title: "EARLIER"),
                    ...earlierItems.map((n) => NotificationListTile(
                          id: n.id,
                          title: n.title,
                          subtitle: n.subtitle,
                          time: n.time,
                          icon: n.icon,
                          iconBg: n.iconBg,
                          iconColor: n.iconColor,
                          isUnread: n.isUnread,
                          onTap: () => _handleNotificationTap(n),
                          onDelete: () => _deleteNotification(n.id),
                        )),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
