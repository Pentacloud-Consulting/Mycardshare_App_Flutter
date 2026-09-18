import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'section': 'TODAY',
      'category': 'leads',
      'title': 'New lead captured!',
      'subtitle': 'Sarah Jenkins viewed your card and left contact info',
      'time': '2m ago',
      'icon': Icons.person_add_rounded,
      'iconBg': const Color(0xFFDCFCE7),
      'iconColor': const Color(0xFF16A34A),
      'isUnread': true,
      'route': '/portal/leads',
    },
    {
      'id': '2',
      'section': 'TODAY',
      'category': 'scans',
      'title': 'Card scanned',
      'subtitle': 'Someone scanned your QR code at GITEX 2026',
      'time': '1h ago',
      'icon': Icons.qr_code_scanner_rounded,
      'iconBg': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
      'isUnread': true,
      'route': '/portal/vault',
    },
    {
      'id': '3',
      'section': 'YESTERDAY',
      'category': 'scans',
      'title': 'Voice contact saved',
      'subtitle': 'Robert Chen added to your Contact Vault',
      'time': 'Yesterday, 4:30 PM',
      'icon': Icons.mic_rounded,
      'iconBg': const Color(0xFFF3E8FF),
      'iconColor': const Color(0xFF9333EA),
      'isUnread': false,
      'route': '/portal/vault',
    },
    {
      'id': '4',
      'section': 'YESTERDAY',
      'category': 'system',
      'title': 'Profile update approved',
      'subtitle': 'Your admin approved your title change',
      'time': 'Yesterday, 11:00 AM',
      'icon': Icons.check_circle_rounded,
      'iconBg': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
      'isUnread': false,
      'route': '/portal/profile',
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var item in _notifications) {
        item['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All notifications marked as read!"),
        backgroundColor: Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Notification deleted"),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _notifications.where((n) {
      if (_selectedFilter == 'all') return true;
      return n['category'] == _selectedFilter;
    }).toList();

    final todayItems = filteredList.where((n) => n['section'] == 'TODAY').toList();
    final yesterdayItems = filteredList.where((n) => n['section'] == 'YESTERDAY').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Row (Mark All Read)
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
                  TextButton(
                    onPressed: _markAllRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Mark all read",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
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

              if (filteredList.isEmpty) ...[
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.notifications_none_rounded, size: 48, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 12),
                      Text(
                        "No notifications found",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],

              // TODAY Section
              if (todayItems.isNotEmpty) ...[
                const NotificationSectionHeader(title: "TODAY"),
                ...todayItems.map((n) => NotificationListTile(
                      id: n['id'],
                      title: n['title'],
                      subtitle: n['subtitle'],
                      time: n['time'],
                      icon: n['icon'],
                      iconBg: n['iconBg'],
                      iconColor: n['iconColor'],
                      isUnread: n['isUnread'],
                      onTap: () {
                        setState(() => n['isUnread'] = false);
                        if (n['route'] != null) context.push(n['route']);
                      },
                      onDelete: () => _deleteNotification(n['id']),
                    )),
              ],

              // YESTERDAY Section
              if (yesterdayItems.isNotEmpty) ...[
                const NotificationSectionHeader(title: "YESTERDAY"),
                ...yesterdayItems.map((n) => NotificationListTile(
                      id: n['id'],
                      title: n['title'],
                      subtitle: n['subtitle'],
                      time: n['time'],
                      icon: n['icon'],
                      iconBg: n['iconBg'],
                      iconColor: n['iconColor'],
                      isUnread: n['isUnread'],
                      onTap: () {
                        setState(() => n['isUnread'] = false);
                        if (n['route'] != null) context.push(n['route']);
                      },
                      onDelete: () => _deleteNotification(n['id']),
                    )),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
