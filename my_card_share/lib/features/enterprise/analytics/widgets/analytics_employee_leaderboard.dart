import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/home_backend/top_performance.dart';

class AnalyticsEmployeeLeaderboard extends StatelessWidget {
  const AnalyticsEmployeeLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<List<TopPerformerData>>(
      stream: EnterpriseTopPerformanceService.instance.streamTopPerformers(uid),
      builder: (context, snapshot) {
        final performers = snapshot.data ?? const [];

        if (performers.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: const Column(
              children: [
                Icon(Icons.leaderboard_outlined, size: 36, color: Color(0xFF94A3B8)),
                SizedBox(height: 8),
                Text(
                  "No Leaderboard Data Yet",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Employee card interactions will populate the leaderboard here.",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final maxViews = performers.first.views > 0 ? performers.first.views.toDouble() : 1.0;

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
                itemCount: performers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final performer = performers[index];
                  final progress = (performer.views / maxViews).clamp(0.05, 1.0);

                  Color rankBg = const Color(0xFFF1F5F9);
                  Color rankTextColor = const Color(0xFF64748B);
                  Color progressColor = const Color(0xFF0052FF);

                  if (performer.rank == 1) {
                    rankBg = const Color(0xFFFEF3C7);
                    rankTextColor = const Color(0xFFD97706);
                    progressColor = const Color(0xFF0052FF);
                  } else if (performer.rank == 2) {
                    rankBg = const Color(0xFFF1F5F9);
                    rankTextColor = const Color(0xFF475569);
                    progressColor = const Color(0xFF7C3AED);
                  } else if (performer.rank == 3) {
                    rankBg = const Color(0xFFFFEDD5);
                    rankTextColor = const Color(0xFFC2410C);
                    progressColor = const Color(0xFF0D9488);
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          // Rank Circle Badge
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: rankBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "${performer.rank}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: rankTextColor,
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
                              performer.initials,
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
                                  performer.name,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  "${performer.views} views · ${performer.leads} leads",
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
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


