import 'package:flutter/material.dart';
import 'widgets/notification_header_stats.dart';
import 'widgets/notification_filter_pills.dart';
import 'widgets/notification_item_card.dart';
import 'widgets/notification_empty_state.dart';

class EnterpriseNotificationsScreen extends StatefulWidget {
  const EnterpriseNotificationsScreen({super.key});

  @override
  State<EnterpriseNotificationsScreen> createState() =>
      _EnterpriseNotificationsScreenState();
}

class _EnterpriseNotificationsScreenState
    extends State<EnterpriseNotificationsScreen> {
  String _activeFilter = "all";

  List<EnterpriseNotificationItem> _notifications = const [
    EnterpriseNotificationItem(
      id: "1",
      title: "New Lead Synced to Salesforce",
      description:
          "Sarah Jenkins saved card for Robert Chen. Contact exported to CRM leads table.",
      timestamp: "5m ago",
      category: "leads",
      isUnread: true,
      icon: Icons.sync_rounded,
      iconColor: Color(0xFF0052FF),
      bgColor: Color(0xFFEFF6FF),
      actionLabel: "View Lead",
    ),
    EnterpriseNotificationItem(
      id: "2",
      title: "SSO Security Domain Locked",
      description:
          "Domain @acmerealty.com enforced Google SSO authentication for all 34 team members.",
      timestamp: "35m ago",
      category: "security",
      isUnread: true,
      icon: Icons.verified_user_rounded,
      iconColor: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
      actionLabel: "Security Settings",
    ),
    EnterpriseNotificationItem(
      id: "3",
      title: "New Employee Joined Workspace",
      description:
          "David Kim accepted workspace invite link and published company digital card.",
      timestamp: "2h ago",
      category: "team",
      isUnread: true,
      icon: Icons.person_add_rounded,
      iconColor: Color(0xFF7C3AED),
      bgColor: Color(0xFFF3E8FF),
      actionLabel: "View Profile",
    ),
    EnterpriseNotificationItem(
      id: "4",
      title: "HubSpot Webhook Connection Restored",
      description:
          "CRM Webhook connector successfully re-authenticated. 14 queued leads processed.",
      timestamp: "4h ago",
      category: "leads",
      isUnread: false,
      icon: Icons.extension_rounded,
      iconColor: Color(0xFF0D9488),
      bgColor: Color(0xFFCCFBF1),
      actionLabel: "Connector Status",
    ),
    EnterpriseNotificationItem(
      id: "5",
      title: "Q3 Tech Summit Campaign Milestone",
      description:
          "Q3 Tech Summit campaign surpassed 100 leads collected in 7 days.",
      timestamp: "Yesterday",
      category: "leads",
      isUnread: false,
      icon: Icons.campaign_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      actionLabel: "Campaign Analytics",
    ),
  ];

  void _markAllRead() {
    setState(() {
      _notifications = _notifications.map((item) {
        return EnterpriseNotificationItem(
          id: item.id,
          title: item.title,
          description: item.description,
          timestamp: item.timestamp,
          category: item.category,
          isUnread: false,
          icon: item.icon,
          iconColor: item.iconColor,
          bgColor: item.bgColor,
          actionLabel: item.actionLabel,
        );
      }).toList();
    });

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

  @override
  Widget build(BuildContext context) {
    final filteredList = _notifications.where((item) {
      if (_activeFilter == "all") return true;
      if (_activeFilter == "unread") return item.isUnread;
      return item.category == _activeFilter;
    }).toList();

    final unreadCount = _notifications.where((item) => item.isUnread).length;

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

              // Filter Pills Row
              NotificationFilterPills(
                activeFilter: _activeFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
              ),

              const SizedBox(height: 18),

              // Notifications List or Empty State
              if (filteredList.isEmpty)
                NotificationEmptyState(
                  categoryName: _activeFilter,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return NotificationItemCard(
                      item: item,
                      onTap: () {
                        setState(() {
                          _notifications = _notifications.map((n) {
                            if (n.id == item.id) {
                              return EnterpriseNotificationItem(
                                id: n.id,
                                title: n.title,
                                description: n.description,
                                timestamp: n.timestamp,
                                category: n.category,
                                isUnread: false,
                                icon: n.icon,
                                iconColor: n.iconColor,
                                bgColor: n.bgColor,
                                actionLabel: n.actionLabel,
                              );
                            }
                            return n;
                          }).toList();
                        });
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
  }
}
