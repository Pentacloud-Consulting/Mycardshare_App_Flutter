import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view_employee/view_employee_enterprice.dart';
import '../enployee_leads/employee_save_leads.dart';
import '../../../backend/individual/profile/individual_profile_store.dart';

/// Data model representing an enterprise employee's full profile state
/// with complete real backend information and onboarding/filling flags.
class WorkspaceEmployeeProfileData {
  final String employeeId;
  final String enterpriseUid;
  final String uid;
  final String name;
  final String email;
  final String roleTitle;
  final String role; // 'Admin' or 'Employee'
  final String status; // 'Active', 'Pending', 'Pending Invite', 'Inactive'
  final String? avatarUrl;
  final String? bannerUrl;
  final String phoneNumber;
  final String websiteUrl;
  final String shortBio;
  final String companyName;
  final String networkingStatus;
  final int templateIndex;
  final String cardSlug;
  final List<SocialLinkItem> socialLinks;
  final int views;
  final int leads;
  final bool isBannerLocked;
  final String? lockedBannerUrl;
  final bool hasSignedIn; // true if employee has logged in / created user account
  final bool hasFilledData; // true if employee has entered profile information
  final int filledFieldsCount;
  final List<String> filledFields;
  final List<String> missingFields;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkspaceEmployeeProfileData({
    required this.employeeId,
    required this.enterpriseUid,
    required this.uid,
    required this.name,
    required this.email,
    required this.roleTitle,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.bannerUrl,
    required this.phoneNumber,
    required this.websiteUrl,
    required this.shortBio,
    required this.companyName,
    required this.networkingStatus,
    required this.templateIndex,
    required this.cardSlug,
    required this.socialLinks,
    required this.views,
    required this.leads,
    required this.isBannerLocked,
    this.lockedBannerUrl,
    required this.hasSignedIn,
    required this.hasFilledData,
    required this.filledFieldsCount,
    required this.filledFields,
    required this.missingFields,
    this.createdAt,
    this.updatedAt,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) {
      if (email.isNotEmpty) return email[0].toUpperCase();
      return 'EM';
    }
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isPending =>
      !hasSignedIn ||
      status.toLowerCase() == 'pending' ||
      status.toLowerCase() == 'pending invite';

  bool get hasBio =>
      shortBio.trim().isNotEmpty &&
      shortBio != 'No bio added yet.' &&
      shortBio != 'No bio provided.';

  bool get hasPhone => phoneNumber.trim().isNotEmpty;
  bool get hasWebsite => websiteUrl.trim().isNotEmpty;
  bool get hasSocialLinks => socialLinks.isNotEmpty;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  factory WorkspaceEmployeeProfileData.fromFirestore({
    required String employeeId,
    required String enterpriseUid,
    required Map<String, dynamic> empData,
    Map<String, dynamic>? userData,
    int? resolvedViews,
    int? resolvedLeads,
  }) {
    final u = userData ?? {};
    final userDocExists = userData != null && userData.isNotEmpty;

    // Email resolution
    final email = (u['email'] ?? empData['email'] ?? '').toString().trim();

    // Name resolution: prefer users collection if custom, fallback to empData
    final uName = (u['fullName'] ?? u['name'] ?? '').toString().trim();
    final empName = (empData['name'] ?? empData['fullName'] ?? '').toString().trim();
    final name = uName.isNotEmpty && uName != 'User'
        ? uName
        : (empName.isNotEmpty
            ? empName
            : (email.isNotEmpty ? email.split('@').first : 'Team Member'));

    // Role Title resolution
    final uTitle = (u['jobTitle'] ?? '').toString().trim();
    final empTitle = (empData['roleTitle'] ?? empData['jobTitle'] ?? '').toString().trim();
    final roleTitle = uTitle.isNotEmpty && uTitle != 'Member'
        ? uTitle
        : (empTitle.isNotEmpty ? empTitle : 'Employee');

    // Role (Admin vs Employee)
    final role = (empData['role'] ?? u['role'] ?? 'Employee').toString().trim();

    // Status resolution
    final rawStatus = (empData['status'] ?? 'Active').toString().trim();

    // Phone, website, bio, company
    final phone = (u['phoneNumber'] ?? u['phone'] ?? empData['phone'] ?? '').toString().trim();
    final website = (u['websiteUrl'] ?? u['website'] ?? empData['website'] ?? '').toString().trim();
    final bio = (u['shortBio'] ?? u['bio'] ?? '').toString().trim();
    
    // Company resolution: prefer empData, then enterprise doc, then userData, never default if known
    String company = (empData['companyName'] ?? empData['company'] ?? '').toString().trim();
    if (company.isEmpty || company == 'Enterprise Workspace') {
      final uComp = (u['companyName'] ?? u['company'] ?? '').toString().trim();
      if (uComp.isNotEmpty && uComp != 'Enterprise Workspace') {
        company = uComp;
      }
    }
    if (company.isEmpty) {
      company = 'Enterprise Workspace';
    }

    final netStatus = (u['networkingStatus'] ?? 'ACTIVELY NETWORKING').toString().trim();

    // Photos
    final avatar = (u['profilePhoto'] ?? u['avatarUrl'] ?? empData['avatarUrl']) as String?;
    final banner = (u['bannerPhoto'] ?? u['bannerUrl'] ?? empData['lockedBannerUrl']) as String?;

    // Card Slug
    final rawSlug = (u['cardSlug'] ?? empData['cardSlug'] ?? '').toString().trim();
    final cardSlug = rawSlug.isNotEmpty
        ? rawSlug
        : IndividualProfileStore.generateCardSlug(name);

    // Template style index
    final tplStyle = (u['templateStyle'] ?? empData['templateStyle'] ?? '0').toString();
    final templateIndex = IndividualProfileStore.getTemplateIndex(tplStyle);

    // Social links
    final List<SocialLinkItem> socialList = [];
    final rawSocial = u['socialLinks'] ?? empData['socialLinks'];
    if (rawSocial is List) {
      for (final item in rawSocial) {
        if (item is Map) {
          final p = (item['platform'] ?? 'Website').toString();
          final url = (item['url'] ?? '').toString();
          if (url.trim().isNotEmpty) {
            socialList.add(SocialLinkItem(platform: p, url: url));
          }
        }
      }
    }

    // Has user signed in?
    // User has signed in if a user doc exists in Firestore, or if onboardingCompleted is true,
    // or if the employee status is explicitly Active and not 'Pending Invite'.
    final bool hasSignedIn = userDocExists ||
        (rawStatus.toLowerCase() == 'active' &&
            !rawStatus.toLowerCase().contains('pending'));

    // Has employee filled anything?
    // Check if the user has provided actual personal data beyond system defaults
    final List<String> filled = [];
    final List<String> missing = [];

    if (name.isNotEmpty && name != 'Team Member' && name != 'User') {
      filled.add('Name');
    } else {
      missing.add('Name');
    }

    if (roleTitle.isNotEmpty && roleTitle != 'Employee' && roleTitle != 'Member') {
      filled.add('Job Title');
    } else {
      missing.add('Job Title');
    }

    if (phone.isNotEmpty) {
      filled.add('Phone Number');
    } else {
      missing.add('Phone Number');
    }

    if (bio.isNotEmpty && bio != 'No bio added yet.' && bio != 'No bio provided.') {
      filled.add('Bio');
    } else {
      missing.add('Bio');
    }

    if (website.isNotEmpty) {
      filled.add('Website');
    } else {
      missing.add('Website');
    }

    if (socialList.isNotEmpty) {
      filled.add('Social Links (${socialList.length})');
    } else {
      missing.add('Social Links');
    }

    if (avatar != null && avatar.isNotEmpty) {
      filled.add('Profile Photo');
    } else {
      missing.add('Profile Photo');
    }

    // Overall filling check:
    final bool hasFilledData = hasSignedIn &&
        (phone.isNotEmpty ||
            (bio.isNotEmpty && bio != 'No bio added yet.') ||
            website.isNotEmpty ||
            socialList.isNotEmpty ||
            (avatar != null && avatar.isNotEmpty) ||
            u['onboardingCompleted'] == true);

    // Views & leads
    final viewsVal = resolvedViews ??
        (empData['views'] as num?)?.toInt() ??
        (u['views'] as num?)?.toInt() ??
        0;
    final leadsVal = resolvedLeads ??
        (empData['leads'] as num?)?.toInt() ??
        (u['leads'] as num?)?.toInt() ??
        0;

    DateTime? createdAt;
    if (empData['createdAt'] is Timestamp) {
      createdAt = (empData['createdAt'] as Timestamp).toDate();
    } else if (u['createdAt'] is Timestamp) {
      createdAt = (u['createdAt'] as Timestamp).toDate();
    }

    DateTime? updatedAt;
    if (empData['updatedAt'] is Timestamp) {
      updatedAt = (empData['updatedAt'] as Timestamp).toDate();
    } else if (u['updatedAt'] is Timestamp) {
      updatedAt = (u['updatedAt'] as Timestamp).toDate();
    }

    return WorkspaceEmployeeProfileData(
      employeeId: employeeId,
      enterpriseUid: enterpriseUid,
      uid: (empData['uid'] ?? u['uid'] ?? '').toString(),
      name: name,
      email: email,
      roleTitle: roleTitle,
      role: role,
      status: rawStatus,
      avatarUrl: avatar,
      bannerUrl: banner,
      phoneNumber: phone,
      websiteUrl: website,
      shortBio: bio.isNotEmpty ? bio : 'No bio filled yet.',
      companyName: company,
      networkingStatus: netStatus,
      templateIndex: templateIndex,
      cardSlug: cardSlug,
      socialLinks: socialList,
      views: viewsVal,
      leads: leadsVal,
      isBannerLocked: empData['isBannerLocked'] == true,
      lockedBannerUrl: empData['lockedBannerUrl'] as String?,
      hasSignedIn: hasSignedIn,
      hasFilledData: hasFilledData,
      filledFieldsCount: filled.length,
      filledFields: filled,
      missingFields: missing,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Robust, real Backend Service for managing, fetching, and saving
/// particular enterprise employee profiles and view events in the Workspace.
class WorkspaceEmployeeViewService extends ChangeNotifier {
  WorkspaceEmployeeViewService._internal();
  static final WorkspaceEmployeeViewService instance =
      WorkspaceEmployeeViewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Fetches complete profile details for a particular employee.
  /// Cross-checks `enterprises/{enterpriseUid}/employees/{employeeId}` and `users/{uid|email}`.
  Future<WorkspaceEmployeeProfileData> fetchEmployeeProfileDetails({
    required String enterpriseUid,
    required String employeeId,
    String? employeeEmail,
    String? employeeName,
  }) async {
    try {
      final cleanEmail = (employeeEmail ?? '').trim().toLowerCase();
      DocumentSnapshot<Map<String, dynamic>>? empDoc;

      // 1. Fetch employee document under enterprise
      final empRef = _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .doc(employeeId);
      final initialSnap = await empRef.get();

      if (initialSnap.exists && initialSnap.data() != null) {
        empDoc = initialSnap;
      } else if (cleanEmail.isNotEmpty) {
        // Query by email
        final qSnap = await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('employees')
            .where('email', isEqualTo: cleanEmail)
            .limit(1)
            .get();
        if (qSnap.docs.isNotEmpty) {
          empDoc = qSnap.docs.first;
        }
      }

      Map<String, dynamic> empData = empDoc?.data() ?? {};
      final resolvedEmpId = empDoc?.id ?? employeeId;

      // Ensure companyName is fetched directly from the enterprise document if not present on employee
      if (enterpriseUid.isNotEmpty && (!empData.containsKey('companyName') || (empData['companyName'] as String?)?.trim().isEmpty == true)) {
        try {
          final entDoc = await _firestore.collection('enterprises').doc(enterpriseUid).get();
          if (entDoc.exists && entDoc.data() != null) {
            final realComp = (entDoc.data()!['companyName'] as String?)?.trim();
            if (realComp != null && realComp.isNotEmpty) {
              empData['companyName'] = realComp;
            }
          }
        } catch (_) {}
      }

      // If document still doesn't exist, build fallback from email/name
      if (empData.isEmpty) {
        final prefix = cleanEmail.isNotEmpty
            ? cleanEmail.split('@').first
            : (employeeName ?? 'Team Member');
        empData = {
          'id': resolvedEmpId,
          'name': employeeName ?? (prefix.isNotEmpty ? prefix[0].toUpperCase() + prefix.substring(1) : 'Team Member'),
          'email': cleanEmail,
          'roleTitle': 'Employee',
          'role': 'Employee',
          'status': 'Pending Invite',
        };
      }

      // 2. Fetch User document to verify sign-in & filled profile data
      Map<String, dynamic>? userData;
      final candidateUid = (empData['uid'] ?? '').toString().trim();
      final effectiveEmail = (empData['email'] ?? cleanEmail).toString().trim().toLowerCase();

      // Check users/{uid}
      if (candidateUid.isNotEmpty) {
        try {
          final uSnap = await _firestore.collection('users').doc(candidateUid).get();
          if (uSnap.exists && uSnap.data() != null) {
            userData = uSnap.data();
          }
        } catch (_) {}
      }

      // Check users where email == effectiveEmail
      if (userData == null && effectiveEmail.isNotEmpty) {
        try {
          final uQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: effectiveEmail)
              .limit(1)
              .get();
          if (uQuery.docs.isNotEmpty && uQuery.docs.first.data().isNotEmpty) {
            userData = uQuery.docs.first.data();
          }
        } catch (_) {}
      }

      // Check users/{sanitizedEmail}
      if (userData == null && effectiveEmail.isNotEmpty) {
        try {
          final docId = effectiveEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
          final uSnap = await _firestore.collection('users').doc(docId).get();
          if (uSnap.exists && uSnap.data() != null) {
            userData = uSnap.data();
          }
        } catch (_) {}
      }

      // 3. Count exact views from subcollection
      int actualViews = (empData['views'] as num?)?.toInt() ?? 0;
      try {
        final viewsSnap = await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('employees')
            .doc(resolvedEmpId)
            .collection('views')
            .get();
        if (viewsSnap.docs.length > actualViews) {
          actualViews = viewsSnap.docs.length;
        }
      } catch (_) {}

      // 4. Count exact leads
      int actualLeads = (empData['leads'] as num?)?.toInt() ?? 0;
      try {
        if (effectiveEmail.isNotEmpty) {
          final leadsSnap = await _firestore
              .collection('enterprises')
              .doc(enterpriseUid)
              .collection('leads')
              .where('employeeEmail', isEqualTo: effectiveEmail)
              .get();
          if (leadsSnap.docs.length > actualLeads) {
            actualLeads = leadsSnap.docs.length;
          }
        }
      } catch (_) {}

      return WorkspaceEmployeeProfileData.fromFirestore(
        employeeId: resolvedEmpId,
        enterpriseUid: enterpriseUid,
        empData: empData,
        userData: userData,
        resolvedViews: actualViews,
        resolvedLeads: actualLeads,
      );
    } catch (e) {
      debugPrint('[WorkspaceEmployeeViewService] fetchEmployeeProfileDetails error: $e');
      return WorkspaceEmployeeProfileData(
        employeeId: employeeId,
        enterpriseUid: enterpriseUid,
        uid: '',
        name: employeeName ?? 'Team Member',
        email: employeeEmail ?? '',
        roleTitle: 'Employee',
        role: 'Employee',
        status: 'Active',
        phoneNumber: '',
        websiteUrl: '',
        shortBio: 'No bio filled yet.',
        companyName: 'Enterprise Workspace',
        networkingStatus: 'ACTIVELY NETWORKING',
        templateIndex: 0,
        cardSlug: 'user-${DateTime.now().millisecondsSinceEpoch % 1000}',
        socialLinks: const [],
        views: 0,
        leads: 0,
        isBannerLocked: false,
        hasSignedIn: false,
        hasFilledData: false,
        filledFieldsCount: 0,
        filledFields: const [],
        missingFields: const ['Phone', 'Bio', 'Website', 'Social Links'],
      );
    }
  }

  /// Real-time stream of an employee's profile data
  Stream<WorkspaceEmployeeProfileData> streamEmployeeProfile({
    required String enterpriseUid,
    required String employeeId,
    String? employeeEmail,
    String? employeeName,
  }) {
    return _firestore
        .collection('enterprises')
        .doc(enterpriseUid)
        .collection('employees')
        .doc(employeeId)
        .snapshots()
        .asyncMap((_) async {
      return await fetchEmployeeProfileDetails(
        enterpriseUid: enterpriseUid,
        employeeId: employeeId,
        employeeEmail: employeeEmail,
        employeeName: employeeName,
      );
    });
  }

  /// Records an employee profile view event and increments views accurately.
  Future<bool> recordEmployeeProfileView({
    required String enterpriseUid,
    required String employeeId,
    String? employeeEmail,
    String? employeeName,
    String? viewerUid,
    String? viewerName,
    String source = 'workspace_view',
  }) async {
    try {
      final success = await ViewEmployeeEnterpriseService.instance.recordEmployeeView(
        enterpriseUid: enterpriseUid,
        employeeId: employeeId,
        employeeEmail: employeeEmail,
        employeeName: employeeName,
        viewerUid: viewerUid ?? currentUid,
        viewerName: viewerName ?? 'Workspace Admin',
        source: source,
      );

      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[WorkspaceEmployeeViewService] recordEmployeeProfileView error: $e');
      return false;
    }
  }

  /// Saves updated employee details (Role, Job Title, Banner Lock, Phone, etc.)
  Future<bool> updateEmployeeDetails({
    required String enterpriseUid,
    required String employeeId,
    String? employeeUid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final dataWithTimestamp = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Update enterprise employee doc
      await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('employees')
          .doc(employeeId)
          .set(dataWithTimestamp, SetOptions(merge: true));

      // 2. If employeeUid is present, sync shared fields to users/{employeeUid}
      if (employeeUid != null && employeeUid.trim().isNotEmpty) {
        final Map<String, dynamic> userSync = {};
        if (updates.containsKey('roleTitle')) userSync['jobTitle'] = updates['roleTitle'];
        if (updates.containsKey('role')) userSync['role'] = updates['role'];
        if (updates.containsKey('isBannerLocked')) userSync['isBannerLocked'] = updates['isBannerLocked'];
        if (updates.containsKey('lockedBannerUrl')) userSync['lockedBannerUrl'] = updates['lockedBannerUrl'];
        if (updates.containsKey('status')) userSync['status'] = updates['status'];
        if (updates.containsKey('isPublished')) {
          userSync['isPublished'] = updates['isPublished'];
          userSync['cardStatus'] = (updates['isPublished'] == true) ? 'Published' : 'Unpublished';
        }
        if (updates.containsKey('adminSetInactive')) userSync['adminSetInactive'] = updates['adminSetInactive'];

        if (userSync.isNotEmpty) {
          userSync['updatedAt'] = FieldValue.serverTimestamp();
          await _firestore
              .collection('users')
              .doc(employeeUid.trim())
              .set(userSync, SetOptions(merge: true));
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[WorkspaceEmployeeViewService] updateEmployeeDetails error: $e');
      return false;
    }
  }

  /// Toggles enterprise brand banner lock for a specific employee
  Future<bool> toggleBannerLock({
    required String enterpriseUid,
    required String employeeId,
    required bool locked,
    String? bannerUrl,
  }) async {
    return await updateEmployeeDetails(
      enterpriseUid: enterpriseUid,
      employeeId: employeeId,
      updates: {
        'isBannerLocked': locked,
        'lockedBannerUrl': locked ? bannerUrl : null,
      },
    );
  }

  /// Resends employee invitation email / logs notification event
  Future<bool> resendEmployeeInvite({
    required String enterpriseUid,
    required String email,
  }) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      // Update invite timestamp on enterprise
      await _firestore.collection('enterprises').doc(enterpriseUid).set({
        'lastInviteResentAt': FieldValue.serverTimestamp(),
        'invitedEmails': FieldValue.arrayUnion([cleanEmail]),
      }, SetOptions(merge: true));

      // Record a notification event under enterprises/{enterpriseUid}/notifications
      final notifId = 'notif_${DateTime.now().millisecondsSinceEpoch}';
      await _firestore
          .collection('enterprises')
          .doc(enterpriseUid)
          .collection('notifications')
          .doc(notifId)
          .set({
        'id': notifId,
        'title': 'Invitation Resent',
        'message': 'Workspace invitation was resent to $cleanEmail',
        'type': 'invite',
        'targetEmail': cleanEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      return true;
    } catch (e) {
      debugPrint('[WorkspaceEmployeeViewService] resendEmployeeInvite error: $e');
      return false;
    }
  }

  /// Triggers a live sync of views and leads for an employee
  Future<void> syncEmployeeMetrics(String enterpriseUid, String employeeId) async {
    try {
      await ViewEmployeeEnterpriseService.instance.syncEmployeeViews(enterpriseUid);
      await EnterpriseEmployeeSaveLeadsService.instance
          .syncAndRecalculateEmployeeLeads(enterpriseUid);
      notifyListeners();
    } catch (e) {
      debugPrint('[WorkspaceEmployeeViewService] syncEmployeeMetrics note: $e');
    }
  }
}
