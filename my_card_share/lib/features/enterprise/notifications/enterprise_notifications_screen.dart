import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/notification_header_stats.dart';
import 'widgets/notification_filter_pills.dart';
import 'widgets/notification_item_card.dart';
import 'widgets/notification_empty_state.dart';
import '../../../backend/enterprise/home_backend/notifications_service.dart';

class EnterpriseNotificationsScreen extends StatefulWidget {
  const EnterpriseNotificationsScreen({super.key});

  @override
  State<EnterpriseNotificationsScreen> createState() =>
      _EnterpriseNotificationsScreenState();
}

class _EnterpriseNotificationsScreenState
    extends State<EnterpriseNotificationsScreen> {
  String _activeFilter = "all";

  void _markAllRead() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await EnterpriseNotificationsService.instance.markAllAsRead(uid);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("All notifications marked as read."),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'team':
        return Icons.person_add_rounded;
      case 'security':
        return Icons.verified_user_rounded;
      case 'analytics':
        return Icons.bar_chart_rounded;
      case 'leads':
      default:
        return Icons.sync_rounded;
    }
  }

  Color _getIconColorForCategory(String category) {
    switch (category) {
      case 'team':
        return const Color(0xFF7C3AED);
      case 'security':
        return const Color(0xFF059669);
      case 'analytics':
        return const Color(0xFFD97706);
      case 'leads':
      default:
        return const Color(0xFF0052FF);
    }
  }

  Color _getBgColorForCategory(String category) {
    switch (category) {
      case 'team':
        return const Color(0xFFF3E8FF);
      case 'security':
        return const Color(0xFFECFDF5);
      case 'analytics':
        return const Color(0xFFFEF3C7);
      case 'leads':
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<EnterpriseNotificationModel>>(
      stream: EnterpriseNotificationsService.instance.streamAllNotifications(uid),
      builder: (context, snapshot) {
        final allNotifications = snapshot.data ?? [];

        // Real dynamic category counts
        final counts = <String, int>{
          'all': allNotifications.length,
          'unread': allNotifications.where((n) => n.isUnread).length,
          'leads': allNotifications.where((n) => n.category == 'leads').length,
          'team': allNotifications.where((n) => n.category == 'team').length,
          'security': allNotifications.where((n) => n.category == 'security').length,
        };

        // Filter for UI display
        final filteredList = allNotifications.where((item) {
          if (_activeFilter == 'unread') return item.isUnread;
          if (_activeFilter != 'all') return item.category == _activeFilter;
          return true;
        }).toList();

        final unreadCount = counts['unread'] ?? 0;

        final uiItems = filteredList.map((n) {
          return EnterpriseNotificationItem(
            id: n.id,
            title: n.title,
            description: n.description,
            timestamp: n.timeAgo,
            category: n.category,
            isUnread: n.isUnread,
            icon: _getIconForCategory(n.category),
            iconColor: _getIconColorForCategory(n.category),
            bgColor: _getBgColorForCategory(n.category),
            actionLabel: n.category == 'leads'
                ? 'View Lead'
                : n.category == 'team'
                    ? 'View Profile'
                    : n.category == 'security'
                        ? 'Security Settings'
                        : 'Analytics',
          );
        }).toList();

        return Stack(
          children: [
            // Top-Right Soft Baby-Blue Gradient Blob
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.18),
                      const Color(0xFF0052FF).withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Screen Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Summary Banner
                  NotificationHeaderStats(
                    unreadCount: unreadCount,
                    onMarkAllRead: _markAllRead,
                  ),

                  const SizedBox(height: 18),

                  // Filter Pills Row with real dynamic counts
                  NotificationFilterPills(
                    activeFilter: _activeFilter,
                    counts: counts,
                    onFilterChanged: (filter) {
                      setState(() {
                        _activeFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 18),

                  // Notifications List or Empty State
                  if (uiItems.isEmpty)
                    NotificationEmptyState(
                      categoryName: _activeFilter,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: uiItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = uiItems[index];
                        return NotificationItemCard(
                          item: item,
                          onTap: () async {
                            if (uid != null) {
                              await EnterpriseNotificationsService.instance.markAsRead(item.id, uid);
                            }
                            if (!context.mounted) return;
                            if (item.category == 'team') {
                              context.push('/enterprise/settings/requests');
                            }
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


