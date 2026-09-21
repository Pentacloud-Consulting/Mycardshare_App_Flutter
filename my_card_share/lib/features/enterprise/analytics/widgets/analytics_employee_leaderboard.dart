import 'package:flutter/material.dart';

class AnalyticsEmployeeLeaderboard extends StatelessWidget {
  const AnalyticsEmployeeLeaderboard({super.key});

  static const List<Map<String, dynamic>> _leaderboard = [
    {
      "rank": 1,
      "name": "Sarah Jenkins",
      "views": 142,
      "leads": 12,
      "initials": "SJ",
      "rankBg": Color(0xFFFEF3C7),
      "rankTextColor": Color(0xFFD97706),
      "progress": 0.95,
      "progressColor": Color(0xFF0052FF),
    },
    {
      "rank": 2,
      "name": "David Miller",
      "views": 118,
      "leads": 9,
      "initials": "DM",
      "rankBg": Color(0xFFF1F5F9),
      "rankTextColor": Color(0xFF475569),
      "progress": 0.80,
      "progressColor": Color(0xFF7C3AED),
    },
    {
      "rank": 3,
      "name": "Emily Turner",
      "views": 96,
      "leads": 7,
      "initials": "ET",
      "rankBg": Color(0xFFFFEDD5),
      "rankTextColor": Color(0xFFC2410C),
      "progress": 0.65,
      "progressColor": Color(0xFF0D9488),
    },
    {
      "rank": 4,
      "name": "Michael Ross",
      "views": 45,
      "leads": 3,
      "initials": "MR",
      "rankBg": Color(0xFFF8FAFD),
      "rankTextColor": Color(0xFF94A3B8),
      "progress": 0.35,
      "progressColor": Color(0xFFD97706),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🏆 Employee Leaderboard",
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _leaderboard.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = _leaderboard[index];
              final progress = item["progress"] as double;

              return Column(
                children: [
                  Row(
                    children: [
                      // Rank Circle Badge
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: item["rankBg"] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${item["rank"]}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: item["rankTextColor"] as Color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEFF4FF),
                        child: Text(
                          item["initials"] as String,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Name & Metrics
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"] as String,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              "${item["views"]} views · ${item["leads"]} leads",
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Small Horizontal Progress Bar underneath each row
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item["progressColor"] as Color,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
