import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../enterprise/multiple_store/enterprise_multi_store.dart';
import '../../enterprise/profile/enterprise_profile_store.dart';
import '../../individual/multiple_store/individual_multi_store.dart';
import '../../individual/profile/individual_profile_store.dart';

/// Real Backend Service in `lib/backend/employee_join/home/`
/// Manages real session data for Employee Home Dashboard (Name, Company, Role, Avatar, Status).
/// Accurately persists and recovers the employee's personal profile across logins and app launches.
class EmployeeHomeBackendService extends ChangeNotifier {
  EmployeeHomeBackendService._internal() {
    _initSessionListener();
  }
  static final EmployeeHomeBackendService instance = EmployeeHomeBackendService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = "User";
  String _companyName = "Enterprise Workspace";
  String _email = "";
  String _role = "Member";
  String _status = "Actively Networking";
  String? _avatarUrl;
  String? _enterpriseUid;
  bool _isLoading = false;

  String get userName => _userName;
  String get companyName => _companyName;
  String get email => _email;
  String get role => _role;
  String get status => _status;
  String? get avatarUrl => _avatarUrl;
  String? get enterpriseUid => _enterpriseUid;
  bool get isLoading => _isLoading;

  void _initSessionListener() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadEmployeeHomeData();
      }
    });
  }

  /// Loads real employee profile, joined company name, and user info across Firestore and Stores.
  Future<void> loadEmployeeHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fbUser = _auth.currentUser;
      final currentEmail = fbUser?.email?.trim().toLowerCase() ?? '';
      final currentUid = fbUser?.uid ?? '';

      // ── Step 0: Restore cached employee details from SharedPreferences (immediate UI fidelity)
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedEmail = prefs.getString('emp_cached_email') ?? '';
        if (currentEmail.isNotEmpty && cachedEmail == currentEmail) {
          final cName = prefs.getString('emp_cached_name');
          final cCompany = prefs.getString('emp_cached_company');
          final cRole = prefs.getString('emp_cached_role');
          final cAvatar = prefs.getString('emp_cached_avatar');
          final cEntUid = prefs.getString('emp_cached_ent_uid');

          if (cName != null && cName.isNotEmpty && cName != 'User') _userName = cName;
          if (cCompany != null && cCompany.isNotEmpty && cCompany != 'Enterprise Workspace') _companyName = cCompany;
          if (cRole != null && cRole.isNotEmpty) _role = cRole;
          if (cAvatar != null && cAvatar.isNotEmpty) _avatarUrl = cAvatar;
          if (cEntUid != null && cEntUid.isNotEmpty) _enterpriseUid = cEntUid;
          _email = currentEmail;
        }
      } catch (prefErr) {
        debugPrint('[EmployeeHomeBackendService] SharedPreferences cache read note: $prefErr');
      }

      String foundName = "";
      String foundCompany = "";
      String foundRole = "";
      String? foundAvatar;
      String? foundEntUid;

      // ── Step 1: Check IndividualProfileStore for this employee's active card/profile
      final activeIndProfile = IndividualProfileStore.instance.activeProfile;
      if (activeIndProfile != null) {
        if (activeIndProfile.fullName.isNotEmpty && activeIndProfile.fullName != 'User') {
          foundName = activeIndProfile.fullName;
        }
        if (activeIndProfile.jobTitle.isNotEmpty && activeIndProfile.jobTitle != 'Member') {
          foundRole = activeIndProfile.jobTitle;
        }
        if (activeIndProfile.companyName.isNotEmpty && activeIndProfile.companyName != 'Enterprise Workspace') {
          foundCompany = activeIndProfile.companyName;
        }
        if (activeIndProfile.profilePhoto?.isNotEmpty == true) {
          foundAvatar = activeIndProfile.profilePhoto;
        }
      }

      // Also check local stores
      final indUsers = IndividualMultiStore.instance.getAllUsers();
      if (foundName.isEmpty && indUsers.isNotEmpty) {
        final matchedInd = indUsers.firstWhere(
          (u) => u.email.toLowerCase() == currentEmail,
          orElse: () => indUsers.first,
        );
        if (matchedInd.fullName.isNotEmpty && matchedInd.fullName != 'User') {
          foundName = matchedInd.fullName;
        }
      }

      // ── Step 2: Query Firestore `users` collection for UID and emailDocId
      if (currentUid.isNotEmpty || currentEmail.isNotEmpty) {
        try {
          final Map<String, dynamic> mergedUserData = {};

          if (currentUid.isNotEmpty) {
            final snap = await _firestore.collection('users').doc(currentUid).get();
            if (snap.exists && snap.data() != null) {
              mergedUserData.addAll(snap.data() as Map<String, dynamic>);
            }
          }

          if (currentEmail.isNotEmpty) {
            final docId = currentEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            final snap = await _firestore.collection('users').doc(docId).get();
            if (snap.exists && snap.data() != null) {
              final emailData = snap.data() as Map<String, dynamic>;
              emailData.forEach((k, v) {
                if (v != null && (v is! String || v.trim().isNotEmpty)) {
                  if (!mergedUserData.containsKey(k) ||
                      mergedUserData[k] == null ||
                      (mergedUserData[k] is String && (mergedUserData[k] as String).trim().isEmpty)) {
                    mergedUserData[k] = v;
                  }
                }
              });
            }
          }

          if (mergedUserData.isNotEmpty) {
            final fsName = (mergedUserData['fullName'] as String?)?.trim() ?? (mergedUserData['name'] as String?)?.trim();
            final fsCompany = (mergedUserData['companyName'] as String?)?.trim();
            final fsRole = (mergedUserData['roleTitle'] as String?)?.trim() ?? (mergedUserData['jobTitle'] as String?)?.trim();
            final fsAvatar = (mergedUserData['profilePhoto'] as String?)?.trim() ?? (mergedUserData['avatarUrl'] as String?)?.trim();
            final fsEntUid = (mergedUserData['enterpriseUid'] as String?)?.trim();

            if (fsName != null && fsName.isNotEmpty && fsName != 'User') foundName = fsName;
            if (fsCompany != null && fsCompany.isNotEmpty && fsCompany != 'Enterprise Workspace') foundCompany = fsCompany;
            if (fsRole != null && fsRole.isNotEmpty && fsRole != 'Member') foundRole = fsRole;
            if (fsAvatar != null && fsAvatar.isNotEmpty) foundAvatar = fsAvatar;
            if (fsEntUid != null && fsEntUid.isNotEmpty) foundEntUid = fsEntUid;
          }
        } catch (e) {
          debugPrint('[EmployeeHomeBackendService] Firestore users lookup note: $e');
        }
      }

      // ── Step 3: Check enterprise subcollections (target specific enterpriseUid or search across enterprises)
      if (currentEmail.isNotEmpty) {
        try {
          if (foundEntUid != null && foundEntUid.isNotEmpty) {
            // Also directly read enterprise doc to guarantee companyName
            if (foundCompany.isEmpty || foundCompany == 'Enterprise Workspace') {
              try {
                final entDoc = await _firestore.collection('enterprises').doc(foundEntUid).get();
                if (entDoc.exists && entDoc.data() != null) {
                  final c = (entDoc.data()!['companyName'] as String?)?.trim();
                  if (c != null && c.isNotEmpty && c != 'Enterprise Workspace') {
                    foundCompany = c;
                  }
                }
              } catch (_) {}
            }

            final empSnap = await _firestore
                .collection('enterprises')
                .doc(foundEntUid)
                .collection('employees')
                .where('email', isEqualTo: currentEmail)
                .get();

            if (empSnap.docs.isNotEmpty) {
              final data = empSnap.docs.first.data();
              final empName = (data['name'] as String?)?.trim() ?? (data['fullName'] as String?)?.trim();
              final empRole = (data['roleTitle'] as String?)?.trim() ?? (data['jobTitle'] as String?)?.trim();
              final empAvatar = (data['avatarUrl'] as String?)?.trim();
              if (empName != null && empName.isNotEmpty && empName != 'Team Member' && empName != 'User') {
                foundName = empName;
              }
              if (empRole != null && empRole.isNotEmpty && empRole != 'Team Member') {
                foundRole = empRole;
              }
              if (empAvatar != null && empAvatar.isNotEmpty && (foundAvatar == null || foundAvatar.isEmpty)) {
                foundAvatar = empAvatar;
              }
            }
          } else {
            // Find which enterprise this employee belongs to by scanning recent enterprises
            final entSnap = await _firestore.collection('enterprises').limit(20).get();
            for (final doc in entSnap.docs) {
              try {
                final entData = doc.data();
                final comp = (entData['companyName'] as String?)?.trim();
                final invitedList = (entData['invitedEmails'] as List<dynamic>?) ?? [];
                final isInvited = invitedList.any((e) => e.toString().trim().toLowerCase() == currentEmail);

                final empSnap = await _firestore
                    .collection('enterprises')
                    .doc(doc.id)
                    .collection('employees')
                    .where('email', isEqualTo: currentEmail)
                    .get();

                if (empSnap.docs.isNotEmpty || isInvited) {
                  foundEntUid = doc.id;
                  if (comp != null && comp.isNotEmpty && comp != 'Enterprise Workspace') {
                    foundCompany = comp;
                  }

                  if (empSnap.docs.isNotEmpty) {
                    final data = empSnap.docs.first.data();
                    final empName = (data['name'] as String?)?.trim() ?? (data['fullName'] as String?)?.trim();
                    final empRole = (data['roleTitle'] as String?)?.trim() ?? (data['jobTitle'] as String?)?.trim();
                    final empAvatar = (data['avatarUrl'] as String?)?.trim();

                    if (empName != null && empName.isNotEmpty && empName != 'Team Member' && empName != 'User') {
                      foundName = empName;
                    }
                    if (empRole != null && empRole.isNotEmpty && empRole != 'Team Member') {
                      foundRole = empRole;
                    }
                    if (empAvatar != null && empAvatar.isNotEmpty && (foundAvatar == null || foundAvatar.isEmpty)) {
                      foundAvatar = empAvatar;
                    }
                  }
                  break;
                }
              } catch (_) {}
            }
          }
        } catch (e) {
          debugPrint('[EmployeeHomeBackendService] Employee subcollection search note: $e');
        }
      }

      // ── Step 4: Enterprise multi store check
      final entUsers = EnterpriseMultiStore.instance.getAllUsers();
      if (entUsers.isNotEmpty) {
        final entUser = entUsers.firstWhere(
          (u) => u.email.toLowerCase() == currentEmail,
          orElse: () => entUsers.first,
        );
        if ((foundCompany.isEmpty || foundCompany == 'Enterprise Workspace') && entUser.companyName.isNotEmpty) {
          foundCompany = entUser.companyName;
        }
      }

      // ── Step 5: Fallback to active enterprise profile ONLY if company is still empty
      final activeEntProfile = EnterpriseProfileStore.instance.currentProfile;
      if ((foundCompany.isEmpty || foundCompany == 'Enterprise Workspace') && activeEntProfile != null && activeEntProfile.companyName.isNotEmpty) {
        foundCompany = activeEntProfile.companyName;
        foundEntUid ??= activeEntProfile.uid;
      }

      // ── Step 6: Fallback defaults if still empty
      if (foundName.isEmpty) {
        foundName = fbUser?.displayName?.trim().isNotEmpty == true
            ? fbUser!.displayName!.trim()
            : (currentEmail.isNotEmpty ? currentEmail.split('@').first : "User");
      }

      if (foundCompany.isEmpty) {
        foundCompany = "Enterprise Workspace";
      }

      if (foundRole.isEmpty) {
        foundRole = "Member";
      }

      _userName = foundName;
      _companyName = foundCompany;
      _email = currentEmail;
      _role = foundRole;
      _status = "Actively Networking";
      if (foundAvatar != null && foundAvatar.isNotEmpty) {
        _avatarUrl = foundAvatar;
      }
      if (foundEntUid != null && foundEntUid.isNotEmpty) {
        _enterpriseUid = foundEntUid;
      }

      // ── Step 7: Persist resolved data to SharedPreferences for offline & instant launch restoration
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('emp_cached_email', currentEmail);
        await prefs.setString('emp_cached_name', _userName);
        await prefs.setString('emp_cached_company', _companyName);
        await prefs.setString('emp_cached_role', _role);
        if (_avatarUrl != null) {
          await prefs.setString('emp_cached_avatar', _avatarUrl!);
        }
        if (_enterpriseUid != null) {
          await prefs.setString('emp_cached_ent_uid', _enterpriseUid!);
        }
      } catch (cacheErr) {
        debugPrint('[EmployeeHomeBackendService] Error persisting cache: $cacheErr');
      }

      debugPrint('[EmployeeHomeBackendService] Loaded employee home: $_userName @ $_companyName ($_role, avatar: ${_avatarUrl != null ? "yes" : "no"})');
    } catch (e) {
      debugPrint('[EmployeeHomeBackendService] Error loading employee home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates active employee home profile details manually and syncs to cache + Firestore
  Future<void> updateHomeProfile({
    String? userName,
    String? companyName,
    String? role,
    String? avatarUrl,
  }) async {
    if (userName != null && userName.trim().isNotEmpty) _userName = userName.trim();
    if (companyName != null && companyName.trim().isNotEmpty) _companyName = companyName.trim();
    if (role != null && role.trim().isNotEmpty) _role = role.trim();
    if (avatarUrl != null) _avatarUrl = avatarUrl;
    notifyListeners();

    // Cache locally immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_email.isNotEmpty) await prefs.setString('emp_cached_email', _email);
      await prefs.setString('emp_cached_name', _userName);
      await prefs.setString('emp_cached_company', _companyName);
      await prefs.setString('emp_cached_role', _role);
      if (_avatarUrl != null) {
        await prefs.setString('emp_cached_avatar', _avatarUrl!);
      }
      if (_enterpriseUid != null) {
        await prefs.setString('emp_cached_ent_uid', _enterpriseUid!);
      }
    } catch (_) {}

    // Sync to Firestore enterprise employee record and users document
    try {
      final fbUser = _auth.currentUser;
      final currentEmail = fbUser?.email?.trim().toLowerCase() ?? _email;
      final currentUid = fbUser?.uid ?? '';

      final updateData = <String, dynamic>{
        'fullName': _userName,
        'name': _userName,
        'jobTitle': _role,
        'roleTitle': _role,
        'companyName': _companyName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
        updateData['profilePhoto'] = _avatarUrl;
        updateData['avatarUrl'] = _avatarUrl;
      }
      if (_enterpriseUid != null && _enterpriseUid!.isNotEmpty) {
        updateData['enterpriseUid'] = _enterpriseUid;
      }

      if (currentUid.isNotEmpty) {
        await _firestore.collection('users').doc(currentUid).set(updateData, SetOptions(merge: true));
      }
      if (currentEmail.isNotEmpty) {
        final docId = currentEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        await _firestore.collection('users').doc(docId).set(updateData, SetOptions(merge: true));
      }

      if (_enterpriseUid != null && _enterpriseUid!.isNotEmpty && currentEmail.isNotEmpty) {
        final empSnap = await _firestore
            .collection('enterprises')
            .doc(_enterpriseUid)
            .collection('employees')
            .where('email', isEqualTo: currentEmail)
            .get();

        if (empSnap.docs.isNotEmpty) {
          for (final doc in empSnap.docs) {
            await doc.reference.set({
              'name': _userName,
              'fullName': _userName,
              'roleTitle': _role,
              'jobTitle': _role,
              if (_avatarUrl != null) 'avatarUrl': _avatarUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      }
    } catch (fsErr) {
      debugPrint('[EmployeeHomeBackendService] Firestore sync error in updateHomeProfile: $fsErr');
    }
  }
}

