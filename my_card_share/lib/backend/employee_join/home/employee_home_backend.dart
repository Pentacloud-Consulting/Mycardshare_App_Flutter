import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../enterprise/multiple_store/enterprise_multi_store.dart';
import '../../enterprise/profile/enterprise_profile_store.dart';
import '../../individual/multiple_store/individual_multi_store.dart';
import '../../individual/profile/individual_profile_store.dart';

/// Real Backend Service in `lib/backend/employee_join/home/`
/// Manages real session data for Employee Home Dashboard (Name, Company, Role, Avatar, Status).
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

      // 1. Check local multi stores
      final activeEntProfile = EnterpriseProfileStore.instance.currentProfile;
      final entUsers = EnterpriseMultiStore.instance.getAllUsers();
      final indUsers = IndividualMultiStore.instance.getAllUsers();
      final activeIndProfile = IndividualProfileStore.instance.activeProfile;

      String foundName = "";
      String foundCompany = "";
      String foundRole = "Member";
      String? foundAvatar;
      String? foundEntUid;

      // Extract from active profiles/stores first
      if (activeIndProfile != null && activeIndProfile.fullName.isNotEmpty) {
        foundName = activeIndProfile.fullName;
        foundRole = activeIndProfile.jobTitle.isNotEmpty ? activeIndProfile.jobTitle : "Member";
        foundCompany = activeIndProfile.companyName.isNotEmpty ? activeIndProfile.companyName : "";
        foundAvatar = activeIndProfile.profilePhoto;
      }

      if (foundName.isEmpty && indUsers.isNotEmpty) {
        foundName = indUsers.first.fullName;
      }

      if (entUsers.isNotEmpty) {
        final entUser = entUsers.firstWhere(
          (u) => u.email.toLowerCase() == currentEmail,
          orElse: () => entUsers.first,
        );
        if (foundCompany.isEmpty && entUser.companyName.isNotEmpty) {
          foundCompany = entUser.companyName;
        }
      }

      if (foundCompany.isEmpty && activeEntProfile != null && activeEntProfile.companyName.isNotEmpty) {
        foundCompany = activeEntProfile.companyName;
        foundEntUid = activeEntProfile.uid;
      }

      // 2. Query Firestore users collection for matching email / uid
      if (currentUid.isNotEmpty || currentEmail.isNotEmpty) {
        try {
          DocumentSnapshot? userDoc;
          if (currentEmail.isNotEmpty) {
            final docId = currentEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            final snap = await _firestore.collection('users').doc(docId).get();
            if (snap.exists) userDoc = snap;
          }

          if (userDoc == null && currentUid.isNotEmpty) {
            final snap = await _firestore.collection('users').doc(currentUid).get();
            if (snap.exists) userDoc = snap;
          }

          if (userDoc != null && userDoc.data() != null) {
            final data = userDoc.data() as Map<String, dynamic>;
            final fsName = (data['fullName'] as String?)?.trim() ?? (data['name'] as String?)?.trim();
            final fsCompany = (data['companyName'] as String?)?.trim();
            final fsRole = (data['roleTitle'] as String?)?.trim() ?? (data['jobTitle'] as String?)?.trim();
            final fsAvatar = data['avatarUrl'] as String? ?? data['profilePhoto'] as String?;
            final fsEntUid = data['enterpriseUid'] as String?;

            if (fsName != null && fsName.isNotEmpty) foundName = fsName;
            if (fsCompany != null && fsCompany.isNotEmpty) foundCompany = fsCompany;
            if (fsRole != null && fsRole.isNotEmpty) foundRole = fsRole;
            if (fsAvatar != null && fsAvatar.isNotEmpty) foundAvatar = fsAvatar;
            if (fsEntUid != null && fsEntUid.isNotEmpty) foundEntUid = fsEntUid;
          }
        } catch (e) {
          debugPrint('[EmployeeHomeBackendService] Firestore users lookup note: $e');
        }
      }

      // 3. Query active employee subcollection from Firestore
      if (foundEntUid != null && foundEntUid.isNotEmpty && currentEmail.isNotEmpty) {
        try {
          final empSnap = await _firestore
              .collection('enterprises')
              .doc(foundEntUid)
              .collection('employees')
              .get();

          if (empSnap.docs.isNotEmpty) {
            final matchDoc = empSnap.docs.firstWhere(
              (doc) => (doc.data()['email'] as String?)?.toLowerCase() == currentEmail,
              orElse: () => empSnap.docs.first,
            );
            final data = matchDoc.data();
            final empName = (data['name'] as String?)?.trim() ?? (data['fullName'] as String?)?.trim();
            final empRole = (data['roleTitle'] as String?)?.trim() ?? (data['jobTitle'] as String?)?.trim();
            if (empName != null && empName.isNotEmpty && empName != 'Team Member') {
              if (foundName.isEmpty || foundName == 'User') foundName = empName;
            }
            if (empRole != null && empRole.isNotEmpty) {
              foundRole = empRole;
            }
          }
        } catch (e) {
          debugPrint('[EmployeeHomeBackendService] Employee subcollection note: $e');
        }
      }

      // 4. Fallback defaults if still empty
      if (foundName.isEmpty) {
        foundName = fbUser?.displayName?.trim().isNotEmpty == true
            ? fbUser!.displayName!.trim()
            : (currentEmail.isNotEmpty ? currentEmail.split('@').first : "User");
      }

      if (foundCompany.isEmpty) {
        foundCompany = activeEntProfile?.companyName.isNotEmpty == true
            ? activeEntProfile!.companyName
            : "Islamic Web";
      }

      _userName = foundName.isNotEmpty ? foundName : "User";
      _companyName = foundCompany.isNotEmpty ? foundCompany : "Islamic Web";
      _email = currentEmail;
      _role = foundRole.isNotEmpty ? foundRole : "Member";
      _status = "Actively Networking";
      _avatarUrl = foundAvatar;
      _enterpriseUid = foundEntUid ?? activeEntProfile?.uid;

      debugPrint('[EmployeeHomeBackendService] Loaded employee home: $_userName @ $_companyName ($_role)');
    } catch (e) {
      debugPrint('[EmployeeHomeBackendService] Error loading employee home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates active employee home profile details manually
  void updateHomeProfile({
    String? userName,
    String? companyName,
    String? role,
    String? avatarUrl,
  }) {
    if (userName != null && userName.isNotEmpty) _userName = userName;
    if (companyName != null && companyName.isNotEmpty) _companyName = companyName;
    if (role != null && role.isNotEmpty) _role = role;
    if (avatarUrl != null) _avatarUrl = avatarUrl;
    notifyListeners();
  }
}
