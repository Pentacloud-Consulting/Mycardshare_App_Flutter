import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../enterprise/multiple_store/enterprise_multi_store.dart';
import '../../enterprise/profile/enterprise_profile_store.dart';

/// Result model for Employee Email Verification & Workspace Enrollment Check
class EmployeeEmailVerificationResult {
  final bool isEnrolled;
  final String? enterpriseUid;
  final String? companyName;
  final String? employeeName;
  final String message;

  const EmployeeEmailVerificationResult({
    required this.isEnrolled,
    this.enterpriseUid,
    this.companyName,
    this.employeeName,
    required this.message,
  });
}

/// Real Backend Service in `lib/backend/employee_join/email fetch/`
/// Verifies whether an employee work email is registered/enrolled in any Enterprise workspace.
class EmployeeEmailFetchService {
  EmployeeEmailFetchService._internal();
  static final EmployeeEmailFetchService instance = EmployeeEmailFetchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifies if an email address belongs to an enrolled enterprise employee
  Future<EmployeeEmailVerificationResult> verifyEmployeeEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return const EmployeeEmailVerificationResult(
        isEnrolled: false,
        message: "Please enter a valid work email address.",
      );
    }

    try {
      // 1. Check local active profile
      final profile = EnterpriseProfileStore.instance.currentProfile;
      if (profile != null) {
        if (profile.email.toLowerCase() == cleanEmail) {
          return EmployeeEmailVerificationResult(
            isEnrolled: true,
            enterpriseUid: profile.uid,
            companyName: profile.companyName.isNotEmpty ? profile.companyName : 'Islamic Web',
            employeeName: cleanEmail.split('@').first,
            message: "Email is enrolled with ${profile.companyName}.",
          );
        }
      }

      // 2. Check local EnterpriseMultiStore
      final storeUser = EnterpriseMultiStore.instance.getUser(cleanEmail);
      if (storeUser != null) {
        return EmployeeEmailVerificationResult(
          isEnrolled: true,
          enterpriseUid: 'ent_${storeUser.companyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}',
          companyName: storeUser.companyName,
          employeeName: cleanEmail.split('@').first,
          message: "Email is enrolled with ${storeUser.companyName}.",
        );
      }

      // 3. Query Firestore global users collection
      try {
        final docId = cleanEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final userSnap = await _firestore.collection('users').doc(docId).get();
        if (userSnap.exists && userSnap.data() != null) {
          final data = userSnap.data()!;
          final entUid = data['enterpriseUid'] as String?;
          final company = data['companyName'] as String? ?? 'Islamic Web';
          final name = data['fullName'] as String? ?? cleanEmail.split('@').first;
          if (entUid != null && entUid.isNotEmpty) {
            return EmployeeEmailVerificationResult(
              isEnrolled: true,
              enterpriseUid: entUid,
              companyName: company,
              employeeName: name,
              message: "Email is enrolled with $company.",
            );
          }
        }
      } catch (e) {
        debugPrint('[EmployeeEmailFetchService] users doc check note: $e');
      }

      // 4. Query enterprises collection subcollection
      try {
        final entSnap = await _firestore.collection('enterprises').limit(20).get();
        for (final doc in entSnap.docs) {
          try {
            final empSnap = await _firestore
                .collection('enterprises')
                .doc(doc.id)
                .collection('employees')
                .where('email', isEqualTo: cleanEmail)
                .get();

            if (empSnap.docs.isNotEmpty) {
              final empData = empSnap.docs.first.data();
              final company = doc.data()['companyName'] as String? ?? 'Islamic Web';
              final name = empData['name'] as String? ?? cleanEmail.split('@').first;
              return EmployeeEmailVerificationResult(
                isEnrolled: true,
                enterpriseUid: doc.id,
                companyName: company,
                employeeName: name,
                message: "Email is enrolled with $company.",
              );
            }
          } catch (_) {}
        }
      } catch (e) {
        debugPrint('[EmployeeEmailFetchService] enterprises subcollection check note: $e');
      }

      // 5. Default check for pre-seeded enrolled demo accounts (e.g. employee@islamicweb.com, zuhaib@pentacloudconsulting.com)
      final seededEnrolled = ['employee@islamicweb.com', 'zuhaib@pentacloudconsulting.com', 'admin@islamicweb.com'];
      if (seededEnrolled.contains(cleanEmail)) {
        return EmployeeEmailVerificationResult(
          isEnrolled: true,
          enterpriseUid: 'ent_islamic_web',
          companyName: 'Islamic Web',
          employeeName: cleanEmail.split('@').first,
          message: "Email is enrolled with Islamic Web.",
        );
      }
    } catch (e) {
      debugPrint('[EmployeeEmailFetchService] verify email note: $e');
    }

    return EmployeeEmailVerificationResult(
      isEnrolled: false,
      message: "The email '$email' is not enrolled in any enterprise workspace.",
    );
  }

  /// Shows a clean, professional popup dialog when an employee email is not recognized/enrolled.
  static void showEmailNotEnrolledDialog(
    BuildContext context, {
    required String email,
    VoidCallback? onJoinWorkspace,
    VoidCallback? onTryAnother,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 12,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Color(0xFFEF4444),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),

                // Dialog Title
                const Text(
                  "Work Email Not Enrolled",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),

                // Dialog Message Body
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: "We couldn't find an active workspace for "),
                      TextSpan(
                        text: "'$email'",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const TextSpan(
                        text: ".\n\nWrong email, or are you enrolled with your official company email? If you have an invite code, click below to join.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Button: Join Workspace with Code
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      if (onJoinWorkspace != null) {
                        onJoinWorkspace();
                      } else {
                        context.go('/join-workspace');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Join Workspace with Code",
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Button: Try Another Email
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      if (onTryAnother != null) onTryAnother();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Try Another Email",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

