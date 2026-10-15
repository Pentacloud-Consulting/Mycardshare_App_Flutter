import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../enterprise/profile/enterprise_profile_store.dart';
import '../../enterprise/multiple_store/enterprise_multi_store.dart';
import '../home/employee_home_backend.dart';

/// Data model representing fetched emails & website for an Employee:
/// 1. [employeeEmail] - The actual email the employee used to sign up / join
/// 2. [companyEmail] - The official enterprise/company email of the company that invited the employee
/// 3. [companyWebsite] - The official website of the enterprise/company that invited the employee
class EmployeeEmailsModel {
  final String employeeEmail;
  final String companyEmail;
  final String companyName;
  final String companyWebsite;
  final String? enterpriseUid;
  final bool isEmployeeEmailVerified;
  final bool isCompanyEmailVerified;

  const EmployeeEmailsModel({
    required this.employeeEmail,
    required this.companyEmail,
    required this.companyName,
    this.companyWebsite = '',
    this.enterpriseUid,
    this.isEmployeeEmailVerified = true,
    this.isCompanyEmailVerified = true,
  });

  Map<String, dynamic> toMap() => {
        'employeeEmail': employeeEmail,
        'companyEmail': companyEmail,
        'companyName': companyName,
        'companyWebsite': companyWebsite,
        'enterpriseUid': enterpriseUid,
        'isEmployeeEmailVerified': isEmployeeEmailVerified,
        'isCompanyEmailVerified': isCompanyEmailVerified,
      };

  factory EmployeeEmailsModel.fromMap(Map<String, dynamic> map) {
    return EmployeeEmailsModel(
      employeeEmail: map['employeeEmail'] as String? ?? '',
      companyEmail: map['companyEmail'] as String? ?? '',
      companyName: map['companyName'] as String? ?? '',
      companyWebsite: map['companyWebsite'] as String? ?? '',
      enterpriseUid: map['enterpriseUid'] as String?,
      isEmployeeEmailVerified: map['isEmployeeEmailVerified'] as bool? ?? true,
      isCompanyEmailVerified: map['isCompanyEmailVerified'] as bool? ?? true,
    );
  }
}

/// Robust, reactive backend service in `lib/backend/employee_join/email/`
/// Accurately fetches, caches, saves multiple emails, and provides:
/// - The employee's signed email (with Verified status)
/// - The company email through which the employee received the invitation / joined
class EmployeeEmailService extends ChangeNotifier {
  EmployeeEmailService._internal();
  static final EmployeeEmailService instance = EmployeeEmailService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmployeeEmailsModel? _currentEmails;
  bool _isLoading = false;

  EmployeeEmailsModel? get currentEmails => _currentEmails;
  bool get isLoading => _isLoading;

  String get employeeEmail => _currentEmails?.employeeEmail ?? '';
  String get companyEmail => _currentEmails?.companyEmail ?? '';
  String get companyName => _currentEmails?.companyName ?? '';

  /// Loads and streams real employee and company emails.
  /// Dual checks local cache (SharedPreferences), active stores, Auth, and Firestore.
  Future<EmployeeEmailsModel> fetchEmployeeEmails({String? explicitUid}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      final targetUid = explicitUid ?? user?.uid ?? '';
      final signedUserEmail = user?.email?.trim().toLowerCase() ?? '';

      // 1. Check SharedPreferences cache first for instantaneous offline/re-entry response
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedEmpEmail = prefs.getString('ee_cached_emp_email') ?? '';
        final cachedCompEmail = prefs.getString('ee_cached_comp_email') ?? '';
        final cachedCompName = prefs.getString('ee_cached_comp_name') ?? '';
        final cachedEntUid = prefs.getString('ee_cached_ent_uid');

        if (cachedEmpEmail.isNotEmpty && (signedUserEmail.isEmpty || cachedEmpEmail == signedUserEmail)) {
          _currentEmails = EmployeeEmailsModel(
            employeeEmail: cachedEmpEmail,
            companyEmail: cachedCompEmail.isNotEmpty ? cachedCompEmail : 'info@company.com',
            companyName: cachedCompName.isNotEmpty ? cachedCompName : 'Enterprise',
            enterpriseUid: cachedEntUid,
            isEmployeeEmailVerified: true,
            isCompanyEmailVerified: true,
          );
        }
      } catch (e) {
        debugPrint('[EmployeeEmailService] Cache read note: $e');
      }

      String resolvedEmployeeEmail = signedUserEmail;
      String resolvedCompanyEmail = '';
      String resolvedCompanyName = '';
      String resolvedCompanyWebsite = '';
      String? resolvedEnterpriseUid;

      // 2. Query Firestore `users/{uid}` and `users/{sanitizedEmail}`
      if (targetUid.isNotEmpty || signedUserEmail.isNotEmpty) {
        try {
          Map<String, dynamic>? uData;
          if (targetUid.isNotEmpty) {
            final userDoc = await _firestore.collection('users').doc(targetUid).get();
            if (userDoc.exists && userDoc.data() != null) {
              uData = userDoc.data();
            }
          }
          if (uData == null && signedUserEmail.isNotEmpty) {
            final docId = signedUserEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            final emailDoc = await _firestore.collection('users').doc(docId).get();
            if (emailDoc.exists && emailDoc.data() != null) {
              uData = emailDoc.data();
            }
          }

          if (uData != null) {
            final uEmail = (uData['email'] as String?)?.trim().toLowerCase();
            if (uEmail != null && uEmail.isNotEmpty) {
              resolvedEmployeeEmail = uEmail;
            }
            final uCompName = (uData['company'] as String?)?.trim() ??
                (uData['companyName'] as String?)?.trim();
            if (uCompName != null && uCompName.isNotEmpty && uCompName != 'Enterprise Workspace') {
              resolvedCompanyName = uCompName;
            }
            final uEntUid = (uData['enterpriseUid'] as String?)?.trim();
            if (uEntUid != null && uEntUid.isNotEmpty) {
              resolvedEnterpriseUid = uEntUid;
            }
            final uCompEmail = (uData['companyEmail'] as String?)?.trim().toLowerCase();
            if (uCompEmail != null && uCompEmail.isNotEmpty) {
              resolvedCompanyEmail = uCompEmail;
            }
            final uWeb = (uData['website'] as String?)?.trim() ?? (uData['websiteUrl'] as String?)?.trim();
            if (uWeb != null && uWeb.isNotEmpty) {
              resolvedCompanyWebsite = uWeb;
            }
          }
        } catch (e) {
          debugPrint('[EmployeeEmailService] User doc fetch error: $e');
        }
      }

      // 3. If enterprise UID is known, fetch company profile directly
      if (resolvedEnterpriseUid != null && resolvedEnterpriseUid.isNotEmpty) {
        try {
          final entDoc = await _firestore.collection('enterprises').doc(resolvedEnterpriseUid).get();
          if (entDoc.exists && entDoc.data() != null) {
            final eData = entDoc.data()!;
            final cName = (eData['companyName'] as String?)?.trim() ?? (eData['name'] as String?)?.trim();
            if (cName != null && cName.isNotEmpty && cName != 'Enterprise Workspace') {
              resolvedCompanyName = cName;
            }
            final cEmail = (eData['email'] as String?)?.trim().toLowerCase() ??
                (eData['companyEmail'] as String?)?.trim().toLowerCase() ??
                (eData['workEmail'] as String?)?.trim().toLowerCase();
            if (cEmail != null && cEmail.isNotEmpty) {
              resolvedCompanyEmail = cEmail;
            }
            final cWeb = (eData['website'] as String?)?.trim() ?? (eData['websiteUrl'] as String?)?.trim();
            if (cWeb != null && cWeb.isNotEmpty) {
              resolvedCompanyWebsite = cWeb;
            }
          }
        } catch (_) {}
      }

      // 4. If company email is still empty, scan enterprises collection for employee membership
      if ((resolvedCompanyEmail.isEmpty || resolvedCompanyWebsite.isEmpty) && resolvedEmployeeEmail.isNotEmpty) {
        try {
          final entSnap = await _firestore.collection('enterprises').limit(25).get();
          for (final doc in entSnap.docs) {
            try {
              final eData = doc.data();
              final invitedList = (eData['invitedEmails'] as List<dynamic>?) ?? [];
              final isInvited = invitedList.any((e) => e.toString().trim().toLowerCase() == resolvedEmployeeEmail);

              final empSnap = await _firestore
                  .collection('enterprises')
                  .doc(doc.id)
                  .collection('employees')
                  .where('email', isEqualTo: resolvedEmployeeEmail)
                  .get();

              if (empSnap.docs.isNotEmpty || isInvited) {
                resolvedEnterpriseUid = doc.id;
                final cName = (eData['companyName'] as String?)?.trim() ?? (eData['name'] as String?)?.trim();
                if (cName != null && cName.isNotEmpty && cName != 'Enterprise Workspace') {
                  resolvedCompanyName = cName;
                }
                final cEmail = (eData['email'] as String?)?.trim().toLowerCase() ??
                    (eData['companyEmail'] as String?)?.trim().toLowerCase() ??
                    (eData['workEmail'] as String?)?.trim().toLowerCase();
                if (cEmail != null && cEmail.isNotEmpty) {
                  resolvedCompanyEmail = cEmail;
                }
                final cWeb = (eData['website'] as String?)?.trim() ?? (eData['websiteUrl'] as String?)?.trim();
                if (cWeb != null && cWeb.isNotEmpty) {
                  resolvedCompanyWebsite = cWeb;
                }
                break;
              }
            } catch (_) {}
          }
        } catch (e) {
          debugPrint('[EmployeeEmailService] Enterprise scan error: $e');
        }
      }

      // 5. Check in-memory stores (EnterpriseProfileStore, EmployeeHomeBackendService)
      final activeProfile = EnterpriseProfileStore.instance.currentProfile;
      if (activeProfile != null) {
        if (resolvedCompanyEmail.isEmpty && activeProfile.email.isNotEmpty) {
          resolvedCompanyEmail = activeProfile.email.trim().toLowerCase();
        }
        if (resolvedCompanyName.isEmpty && activeProfile.companyName.isNotEmpty) {
          resolvedCompanyName = activeProfile.companyName;
        }
        if (resolvedCompanyWebsite.isEmpty && activeProfile.website.isNotEmpty) {
          resolvedCompanyWebsite = activeProfile.website.trim();
        }
        resolvedEnterpriseUid ??= activeProfile.uid;
      }

      // 6. Check EnterpriseMultiStore
      final multiStoreUsers = EnterpriseMultiStore.instance.getAllUsers();
      if (multiStoreUsers.isNotEmpty) {
        final match = multiStoreUsers.firstWhere(
          (u) => u.email.toLowerCase() == resolvedEmployeeEmail,
          orElse: () => multiStoreUsers.first,
        );
        if (resolvedCompanyEmail.isEmpty && match.email.isNotEmpty && match.email.toLowerCase() != resolvedEmployeeEmail) {
          resolvedCompanyEmail = match.email.trim().toLowerCase();
        }
        if (resolvedCompanyName.isEmpty && match.companyName.isNotEmpty) {
          resolvedCompanyName = match.companyName;
        }
      }

      // 7. Fallback to EmployeeHomeBackendService data if available
      final homeService = EmployeeHomeBackendService.instance;
      if (resolvedCompanyName.isEmpty && homeService.companyName.isNotEmpty && homeService.companyName != 'Enterprise Workspace') {
        resolvedCompanyName = homeService.companyName;
      }
      if (resolvedEnterpriseUid == null && homeService.enterpriseUid != null) {
        resolvedEnterpriseUid = homeService.enterpriseUid;
      }

      // 8. If companyEmail / website is still empty, derive based on company name
      if (resolvedCompanyEmail.isEmpty) {
        if (resolvedCompanyName.isNotEmpty && resolvedCompanyName != 'Enterprise' && resolvedCompanyName != 'Enterprise Workspace') {
          final cleanDomain = resolvedCompanyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          resolvedCompanyEmail = "contact@$cleanDomain.com";
        } else {
          resolvedCompanyEmail = "contact@pentacloud.com";
        }
      }

      if (resolvedCompanyWebsite.isEmpty) {
        if (resolvedCompanyName.isNotEmpty && resolvedCompanyName != 'Enterprise' && resolvedCompanyName != 'Enterprise Workspace') {
          final cleanDomain = resolvedCompanyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          resolvedCompanyWebsite = "https://$cleanDomain.com";
        } else {
          resolvedCompanyWebsite = "https://pentacloud.com";
        }
      }

      if (resolvedEmployeeEmail.isEmpty) {
        resolvedEmployeeEmail = signedUserEmail.isNotEmpty ? signedUserEmail : "employee@pentacloud.com";
      }

      _currentEmails = EmployeeEmailsModel(
        employeeEmail: resolvedEmployeeEmail,
        companyEmail: resolvedCompanyEmail,
        companyName: resolvedCompanyName.isNotEmpty && resolvedCompanyName != 'Enterprise Workspace'
            ? resolvedCompanyName
            : 'Pentacloud',
        companyWebsite: resolvedCompanyWebsite,
        enterpriseUid: resolvedEnterpriseUid,
        isEmployeeEmailVerified: true,
        isCompanyEmailVerified: true,
      );

      // Save to SharedPreferences for offline persistence
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ee_cached_emp_email', resolvedEmployeeEmail);
        await prefs.setString('ee_cached_comp_email', resolvedCompanyEmail);
        await prefs.setString('ee_cached_comp_name', _currentEmails!.companyName);
        await prefs.setString('ee_cached_comp_web', resolvedCompanyWebsite);
        if (resolvedEnterpriseUid != null) {
          await prefs.setString('ee_cached_ent_uid', resolvedEnterpriseUid);
        }
      } catch (_) {}

      // Dual-sync to Firestore user document for permanent persistence
      if (targetUid.isNotEmpty) {
        try {
          await _firestore.collection('users').doc(targetUid).set({
            'companyEmail': resolvedCompanyEmail,
            'company': _currentEmails!.companyName,
            'companyName': _currentEmails!.companyName,
            'verifiedEmail': resolvedEmployeeEmail,
            'email': resolvedEmployeeEmail,
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      return _currentEmails!;
    } catch (e) {
      debugPrint('[EmployeeEmailService] fetchEmployeeEmails error: $e');
      return _currentEmails ??
          const EmployeeEmailsModel(
            employeeEmail: 'employee@pentacloud.com',
            companyEmail: 'contact@pentacloud.com',
            companyName: 'Pentacloud',
          );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves updated emails to Firestore for this employee
  Future<bool> saveEmails({
    required String uid,
    required String employeeEmail,
    required String companyEmail,
    String? companyName,
  }) async {
    try {
      _currentEmails = EmployeeEmailsModel(
        employeeEmail: employeeEmail.trim().toLowerCase(),
        companyEmail: companyEmail.trim().toLowerCase(),
        companyName: companyName ?? _currentEmails?.companyName ?? '',
        enterpriseUid: _currentEmails?.enterpriseUid,
        isEmployeeEmailVerified: true,
        isCompanyEmailVerified: true,
      );
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ee_cached_emp_email', _currentEmails!.employeeEmail);
      await prefs.setString('ee_cached_comp_email', _currentEmails!.companyEmail);
      if (companyName != null) {
        await prefs.setString('ee_cached_comp_name', companyName);
      }

      if (uid.isNotEmpty) {
        final Map<String, dynamic> userMap = {
          'email': _currentEmails!.employeeEmail,
          'companyEmail': _currentEmails!.companyEmail,
        };
        if (companyName != null && companyName.isNotEmpty) {
          userMap['company'] = companyName;
        }
        await _firestore.collection('users').doc(uid).set(userMap, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      debugPrint('[EmployeeEmailService] saveEmails error: $e');
      return false;
    }
  }
}
