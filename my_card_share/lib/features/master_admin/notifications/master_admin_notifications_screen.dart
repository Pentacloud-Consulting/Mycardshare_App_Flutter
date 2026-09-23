import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/back/smart_back_handler.dart';
import '../../auth/font style/font_style.dart';
import 'widgets/notification_filter_chips.dart';
import 'widgets/notification_list_section.dart';
import 'widgets/notification_item_card.dart';

class MasterAdminNotificationsScreen extends StatefulWidget {
  const MasterAdminNotificationsScreen({super.key});

  @override
  State<MasterAdminNotificationsScreen> createState() =>
      _MasterAdminNotificationsScreenState();
}

class _MasterAdminNotificationsScreenState
    extends State<MasterAdminNotificationsScreen> {
  String _selectedFilter = "All";

  List<NotificationModel> _todayList = [
    const NotificationModel(
      id: "1",
      title: "New approval request",
      subtext: "Skyline Brokers submitted an enterprise registration",
      timestamp: "18m ago",
      category: NotificationCategory.approvals,
      isUnread: true,
      icon: Icons.access_time_rounded,
      iconColor: Color(0xFFD97706),
      iconBgColor: Color(0xFFFEF3C7),
      route: "/master-admin/approval",
    ),
    const NotificationModel(
      id: "2",
      title: "System alert",
      subtext: "Storage usage crossed 75% of quota",
      timestamp: "1h ago",
      category: NotificationCategory.system,
      isUnread: true,
      icon: Icons.warning_amber_rounded,
      iconColor: Color(0xFFDC2626),
      iconBgColor: Color(0xFFFEE2E2),
      route: "/master-admin/analytics",
    ),
    const NotificationModel(
      id: "3",
      title: "Company approved",
      subtext: "Acme Realty Group was auto-approved via valid voucher",
      timestamp: "3h ago",
      category: NotificationCategory.approvals,
      isUnread: true,
      icon: Icons.check_circle_outline_rounded,
      iconColor: Color(0xFF16A34A),
      iconBgColor: Color(0xFFDCFCE7),
      route: "/master-admin/company",
    ),
  ];

  List<NotificationModel> _yesterdayList = [
    const NotificationModel(
      id: "4",
      title: "New super admin added",
      subtext: "Fatima Al-Zahrawi was granted platform admin access",
      timestamp: "Yesterday, 6:40 PM",
      category: NotificationCategory.security,
      isUnread: false,
      icon: Icons.shield_outlined,
      iconColor: Color(0xFF7E22CE),
      iconBgColor: Color(0xFFF3E8FF),
      route: "/master-admin/settings",
    ),
    const NotificationModel(
      id: "5",
      title: "Subscription payment failed",
      subtext: "TechNexus Inc's billing charge did not go through",
      timestamp: "Yesterday, 2:10 PM",
      category: NotificationCategory.billing,
      isUnread: false,
      icon: Icons.credit_card_rounded,
      iconColor: Color(0xFF2563EB),
      iconBgColor: Color(0xFFEFF6FF),
      route: "/master-admin/company",
    ),
  ];

  @override
  void initState() {
    super.initState();
    NotificationStore.hasUnreadNotifier.addListener(_onUnreadStateChanged);
  }

  @override
  void dispose() {
    NotificationStore.hasUnreadNotifier.removeListener(_onUnreadStateChanged);
    super.dispose();
  }

  void _onUnreadStateChanged() {
    if (!mounted) return;
    if (!NotificationStore.hasUnreadNotifier.value) {
      setState(() {
        _todayList = _todayList.map((n) => n.copyWith(isUnread: false)).toList();
        _yesterdayList = _yesterdayList.map((n) => n.copyWith(isUnread: false)).toList();
      });
    }
  }

  void _checkGlobalUnreadStatus() {
    final hasUnread =
        _todayList.any((n) => n.isUnread) || _yesterdayList.any((n) => n.isUnread);
    NotificationStore.updateUnreadState(hasUnread);
  }

  void _handleNotificationTap(NotificationModel item) {
    // 1. Mark notification as read
    setState(() {
      _todayList = _todayList.map((n) {
        if (n.id == item.id) return n.copyWith(isUnread: false);
        return n;
      }).toList();

      _yesterdayList = _yesterdayList.map((n) {
        if (n.id == item.id) return n.copyWith(isUnread: false);
        return n;
      }).toList();
    });

    _checkGlobalUnreadStatus();

    // 2. Perform real page redirection to specific screen
    context.push(item.route);
  }

  void _handleNotificationDelete(NotificationModel item) {
    setState(() {
      _todayList.removeWhere((n) => n.id == item.id);
      _yesterdayList.removeWhere((n) => n.id == item.id);
    });

    _checkGlobalUnreadStatus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Cleared notification: ${item.title}"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartPopScope(
      onBack: () => SmartBackHandler.handleMasterAdminBack(context: context),
      child: Stack(
        children: [
          // Soft baby-blue gradient blob top-right corner
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDBEAFE).withValues(alpha: 0.7),
                    const Color(0xFFEFF6FF).withValues(alpha: 0.2),
                    const Color(0xFFF8FAFD).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

        // Main scrollable body
        DefaultTextStyle(
          style: AppFontStyle.bodyMedium,
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips Row
              NotificationFilterChips(
                selectedFilter: _selectedFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Notifications List Section (Today & Yesterday)
              NotificationListSection(
                selectedFilter: _selectedFilter,
                todayNotifications: _todayList,
                yesterdayNotifications: _yesterdayList,
                onItemTap: _handleNotificationTap,
                onItemDelete: _handleNotificationDelete,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ],
    ),
    );
  }
}
