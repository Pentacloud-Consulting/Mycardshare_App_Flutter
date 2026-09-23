import 'package:flutter/material.dart';
import 'notification_item_card.dart';

class NotificationListSection extends StatelessWidget {
  final String selectedFilter;
  final List<NotificationModel> todayNotifications;
  final List<NotificationModel> yesterdayNotifications;
  final Function(NotificationModel)? onItemTap;
  final Function(NotificationModel)? onItemDelete;

  const NotificationListSection({
    super.key,
    required this.selectedFilter,
    required this.todayNotifications,
    required this.yesterdayNotifications,
    this.onItemTap,
    this.onItemDelete,
  });

  @override
  Widget build(BuildContext context) {
    final filteredToday = _filterList(todayNotifications);
    final filteredYesterday = _filterList(yesterdayNotifications);

    if (filteredToday.isEmpty && filteredYesterday.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              "No $selectedFilter notifications",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "You're all caught up for this filter category.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODAY Section
        if (filteredToday.isNotEmpty) ...[
          const Text(
            "TODAY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredToday.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = filteredToday[index];
              return NotificationItemCard(
                notification: item,
                onTap: () => onItemTap?.call(item),
                onDelete: () => onItemDelete?.call(item),
              );
            },
          ),
          const SizedBox(height: 20),
        ],

        // YESTERDAY Section
        if (filteredYesterday.isNotEmpty) ...[
          const Text(
            "YESTERDAY",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredYesterday.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = filteredYesterday[index];
              return NotificationItemCard(
                notification: item,
                onTap: () => onItemTap?.call(item),
                onDelete: () => onItemDelete?.call(item),
              );
            },
          ),
        ],
      ],
    );
  }

  List<NotificationModel> _filterList(List<NotificationModel> source) {
    if (selectedFilter == "All") return source;

    final targetCat = switch (selectedFilter) {
      "Approvals" => NotificationCategory.approvals,
      "System" => NotificationCategory.system,
      "Billing" => NotificationCategory.billing,
      "Security" => NotificationCategory.security,
      _ => null,
    };

    if (targetCat == null) return source;
    return source.where((item) => item.category == targetCat).toList();
  }
}
