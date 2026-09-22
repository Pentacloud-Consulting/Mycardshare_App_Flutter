import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MorePlatformManagementCard extends StatelessWidget {
  const MorePlatformManagementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Lead Audit Logs',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF0052FF),
        'route': '/master-admin/leads',
      },
      {
        'title': 'Global Campaigns',
        'icon': Icons.campaign_rounded,
        'color': const Color(0xFF8B5CF6),
        'route': '/master-admin/campaign',
      },
      {
        'title': 'Platform Analytics',
        'icon': Icons.insights_rounded,
        'color': const Color(0xFF0D9488),
        'route': '/master-admin/analytics',
      },
      {
        'title': 'Workspaces',
        'icon': Icons.workspaces_rounded,
        'color': const Color(0xFFD97706),
        'route': '/master-admin/workspace',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            "PLATFORM MANAGEMENT",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 19,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onTap: () {
                      context.push(item['route'] as String);
                    },
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: Color(0xFFF1F5F9),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
