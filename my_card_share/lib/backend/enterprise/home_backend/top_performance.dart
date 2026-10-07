import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// Data model representing a top performing employee.
class TopPerformerData {
  final String id;
  final String name;
  final String initials;
  final String? avatarUrl;
  final String jobTitle;
  final int views;
  final int leads;
  final int rank;

  const TopPerformerData({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarUrl,
    required this.jobTitle,
    required this.views,
    required this.leads,
    required this.rank,
  });

  factory TopPerformerData.fromFirestore(
      String id, Map<String, dynamic> data, int rank) {
    final name = data['name'] ?? data['fullName'] ?? 'Team Member';
    final parts = name.trim().split(RegExp(r'\s+'));
    String init = 'TM';
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      init = parts[0][0];
      if (parts.length > 1 && parts[1].isNotEmpty) {
        init += parts[1][0];
      }
    }

    return TopPerformerData(
      id: id,
      name: name,
      initials: init.toUpperCase(),
      avatarUrl: data['avatarUrl'] as String?,
      jobTitle: data['roleTitle'] ?? data['jobTitle'] ?? 'Employee',
      views: (data['views'] as num?)?.toInt() ?? 0,
      leads: (data['leads'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}

/// Service handling live top performers streaming and ranking from Firestore.
class EnterpriseTopPerformanceService {
  EnterpriseTopPerformanceService._internal();
  static final EnterpriseTopPerformanceService instance =
      EnterpriseTopPerformanceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Stream of top performers sorted by total views and leads.
  /// Stream of top performers sorted by total views and leads.
  Stream<List<TopPerformerData>> streamTopPerformers([String? uid, int limit = 5]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return const [];
      }

      final docs = snapshot.docs;
      final List<Map<String, dynamic>> employeesWithId = [];

      for (final doc in docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['_id'] = doc.id;
        employeesWithId.add(data);
      }

      // Sort by views descending, then leads descending
      employeesWithId.sort((a, b) {
        final vA = (a['views'] as num?)?.toInt() ?? 0;
        final vB = (b['views'] as num?)?.toInt() ?? 0;
        if (vB != vA) return vB.compareTo(vA);

        final lA = (a['leads'] as num?)?.toInt() ?? 0;
        final lB = (b['leads'] as num?)?.toInt() ?? 0;
        return lB.compareTo(lA);
      });

      final List<TopPerformerData> performers = [];
      for (int i = 0; i < employeesWithId.length && i < limit; i++) {
        final item = employeesWithId[i];
        performers.add(TopPerformerData.fromFirestore(
          item['_id'] as String,
          item,
          i + 1,
        ));
      }

      return performers;
    });
  }
}

/// Real UI Widget corresponding to Image 3 (Top Performers Section).
class EnterpriseTopPerformersBackend extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const EnterpriseTopPerformersBackend({
    super.key,
    this.onSeeAllTap,
  });

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
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(Icons.emoji_events_outlined, size: 36, color: Color(0xFF94A3B8)),
                SizedBox(height: 8),
                Text(
                  "No Top Performers Yet",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Invite team members to track performance metrics.",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top Performers",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAllTap ?? () => context.go('/enterprise/workspace'),
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Top Performers List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: performers.length,
              separatorBuilder: (_, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final performer = performers[index];
                final isTop = performer.rank == 1;

                Color rankBgColor = const Color(0xFFF1F5F9);
                Color rankTextColor = const Color(0xFF64748B);

                if (performer.rank == 1) {
                  rankBgColor = const Color(0xFFFEF3C7);
                  rankTextColor = const Color(0xFFD97706);
                } else if (performer.rank == 2) {
                  rankBgColor = const Color(0xFFF1F5F9);
                  rankTextColor = const Color(0xFF475569);
                } else if (performer.rank == 3) {
                  rankBgColor = const Color(0xFFFFEDD5);
                  rankTextColor = const Color(0xFFC2410C);
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Rank Number Badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rankBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${performer.rank}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: rankTextColor,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Avatar Initials
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: performer.avatarUrl != null &&
                                  performer.avatarUrl!.trim().isNotEmpty
                              ? Image.network(
                                  performer.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, trace) => Center(
                                    child: Text(
                                      performer.initials,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0052FF),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    performer.initials,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0052FF),
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Name + Stats Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              performer.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${performer.views} views · ${performer.leads} leads",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trophy Icon for #1 Performer
                      if (isTop)
                        const Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFFD97706),
                          size: 22,
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}


