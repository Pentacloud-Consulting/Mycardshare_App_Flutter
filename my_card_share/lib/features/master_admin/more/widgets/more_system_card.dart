import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoreSystemCard extends StatelessWidget {
  const MoreSystemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'Platform Settings',
        'icon': Icons.settings_rounded,
        'color': const Color(0xFF475569),
        'route': '/master-admin/settings',
      },
      {
        'title': 'Super Admin Accounts',
        'icon': Icons.vpn_key_rounded,
        'color': const Color(0xFFD97706),
        'route': null,
      },
      {
        'title': 'API Keys — Gemini, Firebase, HuggingFace',
        'icon': Icons.extension_rounded,
        'color': const Color(0xFF2563EB),
        'route': null,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            "SYSTEM",
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onTap: () {
                      if (item['route'] != null) {
                        context.push(item['route'] as String);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${item['title']} configuration"),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
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
