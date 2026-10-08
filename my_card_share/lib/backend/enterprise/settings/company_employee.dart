import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../profile/enterprise_profile_store.dart';
import '../view_employee/view_employee.dart';
import 'employee_popup.dart';

/// Service for managing real enterprise company & employee settings data.
class CompanyEmployeeService {
  CompanyEmployeeService._internal();
  static final CompanyEmployeeService instance = CompanyEmployeeService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Helper to convert raw employeeLimit string/int to numerical max capacity limit.
  static int parseMaxLimit(dynamic rawLimit) {
    if (rawLimit is int) return rawLimit;
    if (rawLimit is num) return rawLimit.toInt();
    if (rawLimit is String) {
      final str = rawLimit.trim();
      if (str.contains('10')) return 10;
      if (str.contains('50')) return 50;
      if (str.contains('200')) return 200;
      if (str.contains('500+')) return 1000;
      if (str.contains('500')) return 500;
      final match = RegExp(r'\d+').firstMatch(str);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 50;
      }
    }
    return 50;
  }

  /// Streams real-time company settings data (name, plan, employee limit, logoUrl).
  Stream<CompanySettingsData> streamCompanySettings([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(CompanySettingsData.defaultData());
    }

    return _firestore.collection('enterprises').doc(targetUid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      final profile = EnterpriseProfileStore.instance.currentProfile;

      final companyName = data['companyName'] as String? ?? profile?.companyName ?? 'Enterprise Workspace';
      final logoUrl = data['logoUrl'] as String? ?? profile?.logoUrl;
      final plan = data['planName'] as String? ?? data['plan'] as String? ?? 'Enterprise Pro';
      final rawLimit = data['employeeLimit'] ?? 'Up to 50 employees';
      final maxLimit = parseMaxLimit(rawLimit);
      final rawLimitStr = rawLimit is String ? rawLimit : "Up to $maxLimit employees";

      return CompanySettingsData(
        uid: targetUid,
        companyName: companyName,
        logoUrl: logoUrl,
        planName: plan.startsWith('Enterprise') ? plan : 'Enterprise $plan',
        employeeLimitStr: rawLimitStr,
        maxLimit: maxLimit,
      );
    });
  }

  /// Updates employee limit setting in Firestore.
  Future<void> updateEmployeeLimit({
    required String limitOption,
    String? uid,
  }) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return;

    final maxVal = parseMaxLimit(limitOption);

    await _firestore.collection('enterprises').doc(targetUid).set({
      'employeeLimit': limitOption,
      'maxEmployeeLimit': maxVal,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update local profile store if present
    final profile = EnterpriseProfileStore.instance.currentProfile;
    if (profile != null) {
      EnterpriseProfileStore.instance.setCurrentProfile(
        profile.copyWith(updatedAt: DateTime.now()),
      );
    }
  }
}

/// Model carrying real company settings values.
class CompanySettingsData {
  final String uid;
  final String companyName;
  final String? logoUrl;
  final String planName;
  final String employeeLimitStr;
  final int maxLimit;

  CompanySettingsData({
    required this.uid,
    required this.companyName,
    this.logoUrl,
    required this.planName,
    required this.employeeLimitStr,
    required this.maxLimit,
  });

  factory CompanySettingsData.defaultData() => CompanySettingsData(
        uid: '',
        companyName: 'Acme Realty Group',
        planName: 'Enterprise Pro',
        employeeLimitStr: 'Up to 50 employees',
        maxLimit: 50,
      );
}

/// Frontend Widget for Image 1 (Settings Top Company Card).
/// Real-time streamed with company name, employee count, and plan info.
class SettingsCompanySummaryHeader extends StatelessWidget {
  final VoidCallback? onEditTap;
  final String? uid;

  const SettingsCompanySummaryHeader({
    super.key,
    this.onEditTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<CompanySettingsData>(
      stream: CompanyEmployeeService.instance.streamCompanySettings(targetUid),
      builder: (context, settingsSnap) {
        final settings = settingsSnap.data ?? CompanySettingsData.defaultData();

        return StreamBuilder<int>(
          stream: ViewEmployeeService.instance.streamEmployeeCount(targetUid),
          builder: (context, countSnap) {
            final activeCount = countSnap.data ?? 0;
            final subtitleText = "$activeCount employees · ${settings.planName}";

            return Container(
              padding: const EdgeInsets.all(14),
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
              child: Row(
                children: [
                  // Company Logo / Gradient Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: settings.logoUrl != null && settings.logoUrl!.isNotEmpty
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      image: settings.logoUrl != null && settings.logoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(settings.logoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: settings.logoUrl == null || settings.logoUrl!.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(width: 12),

                  // Center: Company Name & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.companyName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitleText,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Small Blue "Edit" Link Button (Image 1 style)
                  GestureDetector(
                    onTap: () {
                      if (onEditTap != null) {
                        onEditTap!();
                      } else {
                        context.push('/enterprise/brand-profile');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0052FF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Frontend Row Widget for Image 2 (Employee Limit setting row).
/// Shows real `{used} / {limit} used >` and triggers employee limit popup modal.
class SettingsEmployeeLimitRow extends StatelessWidget {
  final VoidCallback? onTap;
  final String? uid;

  const SettingsEmployeeLimitRow({
    super.key,
    this.onTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<CompanySettingsData>(
      stream: CompanyEmployeeService.instance.streamCompanySettings(targetUid),
      builder: (context, settingsSnap) {
        final settings = settingsSnap.data ?? CompanySettingsData.defaultData();

        return StreamBuilder<int>(
          stream: ViewEmployeeService.instance.streamEmployeeCount(targetUid),
          builder: (context, countSnap) {
            final usedCount = countSnap.data ?? 0;
            final trailingLabel = "$usedCount / ${settings.maxLimit} used";

            return InkWell(
              onTap: onTap ?? () => showEmployeeLimitPopup(context, uid: targetUid),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    // Mint/Teal rounded square icon with two people 👥 (Image 2 style)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCFBF1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.group_outlined,
                        color: Color(0xFF0D9488),
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Employee Limit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      trailingLabel,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
