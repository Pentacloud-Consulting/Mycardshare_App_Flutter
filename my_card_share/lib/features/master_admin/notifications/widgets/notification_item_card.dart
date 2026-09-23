import 'package:flutter/material.dart';

enum NotificationCategory {
  approvals,
  system,
  billing,
  security,
}

class NotificationStore {
  static final ValueNotifier<bool> hasUnreadNotifier = ValueNotifier<bool>(true);

  static void markAllAsRead() {
    hasUnreadNotifier.value = false;
  }

  static void updateUnreadState(bool hasUnread) {
    hasUnreadNotifier.value = hasUnread;
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String subtext;
  final String timestamp;
  final NotificationCategory category;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String route;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.subtext,
    required this.timestamp,
    required this.category,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.route,
  });

  NotificationModel copyWith({
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      subtext: subtext,
      timestamp: timestamp,
      category: category,
      isUnread: isUnread ?? this.isUnread,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      route: route,
    );
  }
}

class NotificationItemCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isUnread ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isUnread
              ? const Color(0xFFBFDBFE)
              : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: notification.isUnread
            ? [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread Blue Dot Indicator
              if (notification.isUnread)
                Container(
                  margin: const EdgeInsets.only(top: 14, right: 8),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 4),

              // Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: notification.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),

              // Content Column (Title, Subtext, Timestamp)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notification.timestamp,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtext,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Subtle Trash Icon Hint
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 18,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
