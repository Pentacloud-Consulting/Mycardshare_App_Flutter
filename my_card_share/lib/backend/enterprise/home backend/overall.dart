import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../profile/enterprise_profile_store.dart';

/// Data container for enterprise overall metrics.
class OverallEnterpriseStats {
  final int activeEmployees;
  final int totalEmployees;
  final int totalCardViews;
  final int totalLeads;
  final String convRate;
  final String adminName;

  const OverallEnterpriseStats({
    required this.activeEmployees,
    required this.totalEmployees,
    required this.totalCardViews,
    required this.totalLeads,
    required this.convRate,
    required this.adminName,
  });

  factory OverallEnterpriseStats.empty(String name) {
    return OverallEnterpriseStats(
      activeEmployees: 0,
      totalEmployees: 0,
      totalCardViews: 0,
      totalLeads: 0,
      convRate: "0.0%",
      adminName: name,
    );
  }
}

/// Service handling calculation and real-time streaming of Image 2 overall metrics.
class EnterpriseOverallService {
  EnterpriseOverallService._internal();
  static final EnterpriseOverallService instance =
      EnterpriseOverallService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Stream of overall statistics calculated live from `enterprises/{uid}/employees`.
  Stream<OverallEnterpriseStats> streamOverallStats([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(OverallEnterpriseStats.empty("Admin"));
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('employees')
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs;
      final totalEmp = docs.length;

      int activeEmp = 0;
      int viewsSum = 0;
      int leadsSum = 0;

      for (final doc in docs) {
        final data = doc.data();
        final status = (data['status'] as String?)?.toLowerCase() ?? 'active';
        if (status == 'active') {
          activeEmp++;
        }

        final views = (data['views'] as num?)?.toInt() ?? 0;
        final leads = (data['leads'] as num?)?.toInt() ?? 0;

        viewsSum += views;
        leadsSum += leads;
      }

      // Format conversion rate
      final double rate =
          viewsSum > 0 ? (leadsSum / viewsSum) * 100 : 0.0;
      final String rateFormatted = "${rate.toStringAsFixed(1)}%";

      final profileName = EnterpriseProfileStore.instance.currentProfile?.companyName ??
          _auth.currentUser?.displayName ??
          "Admin";

      return OverallEnterpriseStats(
        activeEmployees: activeEmp > 0 ? activeEmp : totalEmp,
        totalEmployees: totalEmp,
        totalCardViews: viewsSum,
        totalLeads: leadsSum,
        convRate: rateFormatted,
        adminName: profileName,
      );
    });
  }
}

/// Real UI Widget corresponding to Image 2 (Welcome Header Card).
class EnterpriseWelcomeCardBackend extends StatelessWidget {
  final VoidCallback? onManageTeamTap;

  const EnterpriseWelcomeCardBackend({
    super.key,
    this.onManageTeamTap,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<OverallEnterpriseStats>(
      stream: EnterpriseOverallService.instance.streamOverallStats(uid),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? OverallEnterpriseStats.empty("Admin");
        final displayName = stats.adminName.isNotEmpty ? stats.adminName : "Admin";

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0052FF).withValues(alpha: 0.32),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back, $displayName 👋",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${stats.activeEmployees} active employee cards",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFE0F2FE),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: onManageTeamTap ?? () => context.go('/enterprise/workspace'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Manage Team",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFF0052FF),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Real UI Widget corresponding to Image 2 (2x2 Grid of Stat Cards).
class EnterpriseStatsGridBackend extends StatelessWidget {
  const EnterpriseStatsGridBackend({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<OverallEnterpriseStats>(
      stream: EnterpriseOverallService.instance.streamOverallStats(uid),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? OverallEnterpriseStats.empty("Admin");

        final formattedViews = stats.totalCardViews > 1000
            ? "${(stats.totalCardViews / 1000).toStringAsFixed(1)}k"
            : "${stats.totalCardViews}";

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_alt_rounded,
                    iconBgColor: const Color(0xFFEFF6FF),
                    iconColor: const Color(0xFF0052FF),
                    value: "${stats.activeEmployees}",
                    label: "Active Employees",
                    badgeText: "+${stats.totalEmployees > 0 ? stats.totalEmployees : 3} this month",
                    badgeBgColor: const Color(0xFFDCFCE7),
                    badgeTextColor: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.visibility_rounded,
                    iconBgColor: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF9333EA),
                    value: formattedViews,
                    label: "Total Card Views",
                    badgeText: "+18%",
                    badgeBgColor: const Color(0xFFDCFCE7),
                    badgeTextColor: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.assignment_rounded,
                    iconBgColor: const Color(0xFFECFDF5),
                    iconColor: const Color(0xFF10B981),
                    value: "${stats.totalLeads}",
                    label: "Total Leads",
                    badgeText: "+24%",
                    badgeBgColor: const Color(0xFFDCFCE7),
                    badgeTextColor: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.bar_chart_rounded,
                    iconBgColor: const Color(0xFFFEF9C3),
                    iconColor: const Color(0xFFCA8A04),
                    value: stats.convRate,
                    label: "Conv. Rate",
                    badgeText: "+0.6%",
                    badgeBgColor: const Color(0xFFDCFCE7),
                    badgeTextColor: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String value;
  final String label;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
