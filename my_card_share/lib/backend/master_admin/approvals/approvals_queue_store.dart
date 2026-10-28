import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../employee_join/email_send_request.dart';
import '../../enterprise/request/request_fetch.dart';
import '../core/master_admin_api_client.dart';
import '../core/master_admin_endpoints.dart';
import '../master_approval_service.dart';
import '../companies/company_management_store.dart';

/// Data model representing any pending approval item in Master Admin
class MasterApprovalItem {
  final String id;
  final String title; // Company name or Applicant name
  final String email; // Company email or Applicant email
  final String type; // 'company' or 'join_request'
  final String targetCompany; // For join requests
  final String? domain;
  final String? logoUrl;
  final String status;
  final DateTime createdAt;
  final EnterpriseJoinRequestModel? rawJoinRequest;

  const MasterApprovalItem({
    required this.id,
    required this.title,
    required this.email,
    required this.type,
    this.targetCompany = '',
    this.domain,
    this.logoUrl,
    required this.status,
    required this.createdAt,
    this.rawJoinRequest,
  });

  String get initials {
    final clean = title.trim();
    if (clean.isEmpty) return 'CO';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// State store managing platform-wide approval queue for Master Admin
class ApprovalsQueueStore extends ChangeNotifier {
  static final ApprovalsQueueStore instance = ApprovalsQueueStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasterApprovalItem> _pendingItems = [];
  final bool _isLoading = false;

  List<MasterApprovalItem> get pendingItems => _pendingItems;
  List<EnterpriseJoinRequestModel> get pendingQueue =>
      _pendingItems
          .where((i) => i.rawJoinRequest != null)
          .map((i) => i.rawJoinRequest!)
          .toList();

  final Set<String> _locallyResolvedIds = {};
  final Set<String> _locallyResolvedTitles = {};
  bool _initializedPrefs = false;

  ApprovalsQueueStore._internal() {
    _loadPersistedResolved();
  }

  Future<void> _loadPersistedResolved() async {
    if (_initializedPrefs) return;
    _initializedPrefs = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('master_admin_resolved_ids') ?? [];
      final titles = prefs.getStringList('master_admin_resolved_titles') ?? [];
      _locallyResolvedIds.addAll(ids);
      _locallyResolvedTitles.addAll(titles.map((t) => t.toLowerCase().trim()));
      notifyListeners();
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] Error loading resolved prefs: $e');
    }
  }

  bool isResolved(String id, [String? title]) {
    if (_locallyResolvedIds.contains(id)) return true;
    if (title != null && _locallyResolvedTitles.contains(title.toLowerCase().trim())) {
      return true;
    }
    return false;
  }

  void markLocallyResolved(String id, {String? title}) async {
    _locallyResolvedIds.add(id);
    if (title != null && title.trim().isNotEmpty) {
      _locallyResolvedTitles.add(title.toLowerCase().trim());
    }
    _pendingItems.removeWhere((i) =>
        i.id == id ||
        (title != null && i.title.toLowerCase().trim() == title.toLowerCase().trim()));
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('master_admin_resolved_ids', _locallyResolvedIds.toList());
      await prefs.setStringList('master_admin_resolved_titles', _locallyResolvedTitles.toList());
    } catch (_) {}
  }

  int get pendingCount => _pendingItems.where((i) => !isResolved(i.id, i.title)).length;
  bool get isLoading => _isLoading;

  Future<void> refreshQueue() async {
    await CompanyManagementStore.instance.loadGlobalCompanies();
    notifyListeners();
  }

  /// Combined real-time stream of pending companies + pending join requests
  Stream<List<MasterApprovalItem>> streamPendingQueue() {
    // Listen to enterprises collection for pending / approvalStatus == pending / isSuspended
    return _firestore.collection('enterprises').snapshots().asyncMap((companySnap) async {
      await _loadPersistedResolved();
      final List<MasterApprovalItem> items = [];

      // 1. Pending Enterprises
      for (final doc in companySnap.docs) {
        if (_locallyResolvedIds.contains(doc.id)) continue;

        final data = doc.data();
        final status = (data['status'] as String? ?? '').toLowerCase().trim();
        final approvalStatus = (data['approvalStatus'] as String? ?? '').toLowerCase().trim();
        final isSuspended = data['isSuspended'] == true;
        final title = (data['companyName'] ?? data['name'] ?? '').toString().trim();

        if (_locallyResolvedTitles.contains(title.toLowerCase())) continue;

        // If explicitly approved, active, rejected, or suspended, it is NOT pending!
        if (approvalStatus == 'approved' ||
            status == 'active' ||
            approvalStatus == 'rejected' ||
            status == 'rejected' ||
            status == 'suspended' ||
            isSuspended) {
          continue;
        }

        if (status == 'pending' || approvalStatus == 'pending') {
          DateTime created = DateTime.now();
          if (data['createdAt'] is Timestamp) {
            created = (data['createdAt'] as Timestamp).toDate();
          }

          items.add(
            MasterApprovalItem(
              id: doc.id,
              title: title.isNotEmpty ? title : 'Pending Enterprise',
              email: data['email'] ?? '',
              type: 'company',
              domain: data['domain'] ?? data['customDomain'] ?? '${doc.id.toLowerCase()}.mycardshare.com',
              logoUrl: data['logoUrl'],
              status: approvalStatus.isNotEmpty ? approvalStatus : (status.isNotEmpty ? status : 'pending'),
              createdAt: created,
            ),
          );
        }
      }

      // 1b. Check companies collection across all documents for pending status
      try {
        final compPendingSnap = await _firestore.collection('companies').get();
        for (final doc in compPendingSnap.docs) {
          if (_locallyResolvedIds.contains(doc.id)) continue;

          final data = doc.data();
          final status = (data['status'] as String? ?? '').toLowerCase().trim();
          final approvalStatus = (data['approvalStatus'] as String? ?? '').toLowerCase().trim();
          final isSuspended = data['isSuspended'] == true;
          final title = (data['companyName'] ?? data['name'] ?? '').toString().trim();

          if (_locallyResolvedTitles.contains(title.toLowerCase())) continue;

          if (approvalStatus == 'approved' ||
              status == 'active' ||
              approvalStatus == 'rejected' ||
              status == 'rejected' ||
              status == 'suspended' ||
              isSuspended) {
            continue;
          }

          if (status == 'pending' || approvalStatus == 'pending') {
            if (!items.any((it) => it.id == doc.id || it.title.toLowerCase() == title.toLowerCase())) {
              DateTime created = DateTime.now();
              if (data['createdAt'] is Timestamp) {
                created = (data['createdAt'] as Timestamp).toDate();
              }
              items.add(
                MasterApprovalItem(
                  id: doc.id,
                  title: title.isNotEmpty ? title : 'Pending Enterprise',
                  email: data['email'] ?? data['adminEmail'] ?? '',
                  type: 'company',
                  domain: data['domain'] ?? data['customDomain'] ?? '${doc.id.toLowerCase()}.mycardshare.com',
                  logoUrl: data['logoUrl'],
                  status: 'pending',
                  createdAt: created,
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[ApprovalsQueueStore] companies collection scan note: $e');
      }

      // 1c. Cross-reference CompanyManagementStore.instance.companies (Global Sync)
      try {
        if (CompanyManagementStore.instance.companies.isEmpty) {
          await CompanyManagementStore.instance.loadGlobalCompanies();
        }
        for (final comp in CompanyManagementStore.instance.companies) {
          if (_locallyResolvedIds.contains(comp.id)) continue;
          final compTitle = comp.name.toLowerCase().trim();
          if (_locallyResolvedTitles.contains(compTitle)) continue;

          final cStatus = comp.status.toLowerCase().trim();
          if (cStatus == 'active' || cStatus == 'suspended' || cStatus == 'rejected') continue;

          if (cStatus == 'pending') {
            if (!items.any((it) => it.id == comp.id || it.title.toLowerCase().trim() == compTitle)) {
              items.add(
                MasterApprovalItem(
                  id: comp.id,
                  title: comp.name,
                  email: comp.email,
                  type: 'company',
                  domain: comp.domain != null && comp.domain!.isNotEmpty
                      ? comp.domain!
                      : '${comp.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}.com',
                  logoUrl: comp.logoUrl,
                  status: 'pending',
                  createdAt: comp.createdAt ?? DateTime.now(),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[ApprovalsQueueStore] CompanyManagementStore scan note: $e');
      }

      // 2. Pending Join Requests
      try {
        final reqSnap = await _firestore
            .collection('enterprise_join_requests')
            .where('status', isEqualTo: 'pending')
            .get();

        for (final doc in reqSnap.docs) {
          final model = EnterpriseJoinRequestModel.fromFirestore(doc.id, doc.data());
          items.add(
            MasterApprovalItem(
              id: doc.id,
              title: model.applicantName.isNotEmpty ? model.applicantName : 'Join Request',
              email: model.applicantEmail,
              type: 'join_request',
              targetCompany: model.enterpriseCompanyName,
              status: model.status,
              createdAt: model.createdAt,
              rawJoinRequest: model,
            ),
          );
        }
      } catch (e) {
        debugPrint('[ApprovalsQueueStore] join_requests query error: $e');
      }

      items.removeWhere((it) => _locallyResolvedIds.contains(it.id));
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _pendingItems = items;
      return items;
    });
  }

  /// Approve an item (either Enterprise company or Join Request)
  Future<bool> approveItem(MasterApprovalItem item) async {
    markLocallyResolved(item.id, title: item.title);
    try {
      if (item.type == 'company') {
        final now = DateTime.now();
        final renewal = now.add(const Duration(days: 365));

        DocumentSnapshot<Map<String, dynamic>>? entDoc;
        try {
          entDoc = await _firestore.collection('enterprises').doc(item.id).get();
        } catch (_) {}
        final entData = entDoc?.data() ?? {};
        final adminUid = (entData['adminUid'] ?? entData['uid'] ?? entData['userId'] ?? item.id).toString();
        final adminEmail = (entData['adminEmail'] ?? entData['email'] ?? item.email).toString().trim().toLowerCase();

        // 1. Unlock enterprise in Firestore enterprises collection
        try {
          await _firestore.collection('enterprises').doc(item.id).set({
            'approvalStatus': 'approved',
            'status': 'Active',
            'isSuspended': false,
            'approvedAt': FieldValue.serverTimestamp(),
            'subscriptionStartDate': Timestamp.fromDate(now),
            'renewalDate': Timestamp.fromDate(renewal),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] enterprises doc update note: $e');
        }

        // 1b. Also update enterprises by companyName to ensure 100% cascade
        try {
          final entByName = await _firestore.collection('enterprises').where('companyName', isEqualTo: item.title).get();
          for (final doc in entByName.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'Active',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}

        // 2. Unlock in companies collection (handles Doc ID, companyId, and slug)
        try {
          await _firestore.collection('companies').doc(item.id).set({
            'approvalStatus': 'approved',
            'status': 'active',
            'isSuspended': false,
            'approvedAt': FieldValue.serverTimestamp(),
            'renewalDate': Timestamp.fromDate(renewal),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          final compSnap = await _firestore
              .collection('companies')
              .where('companyId', isEqualTo: item.id)
              .get();
          for (final doc in compSnap.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'active',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          final compByName = await _firestore.collection('companies').where('companyName', isEqualTo: item.title).get();
          for (final doc in compByName.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'active',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] companies doc update note: $e');
        }

        // 3. Promote Admin User in users collection
        try {
          final targetUserUids = {item.id, if (adminUid.isNotEmpty) adminUid};
          for (final uid in targetUserUids) {
            await _firestore.collection('users').doc(uid).set({
              'approvalStatus': 'approved',
              'status': 'active',
              'role': 'enterprise',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          if (adminEmail.isNotEmpty) {
            final emailDocId = adminEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
            await _firestore.collection('users').doc(emailDocId).set({
              'approvalStatus': 'approved',
              'status': 'active',
              'role': 'enterprise',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            final usersByEmail = await _firestore
                .collection('users')
                .where('email', isEqualTo: adminEmail)
                .get();
            for (final doc in usersByEmail.docs) {
              await doc.reference.set({
                'approvalStatus': 'approved',
                'status': 'active',
                'role': 'enterprise',
                'isSuspended': false,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          }

          final usersSnap = await _firestore
              .collection('users')
              .where('companyId', isEqualTo: item.id)
              .get();
          for (final doc in usersSnap.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'active',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          final usersByCompName = await _firestore
              .collection('users')
              .where('companyName', isEqualTo: item.title)
              .get();
          for (final doc in usersByCompName.docs) {
            await doc.reference.set({
              'approvalStatus': 'approved',
              'status': 'active',
              'role': 'enterprise',
              'isSuspended': false,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] users doc update note: $e');
        }

        // 4. Notify Next.js live backend sync API (/api/sync/master-admin)
        try {
          await MasterApprovalSyncService.approveCompany(
            companyId: item.id,
            action: 'approve',
          );
        } catch (apiErr) {
          debugPrint('[ApprovalsQueueStore] MasterApprovalSyncService error: $apiErr');
        }

        // 5. Notify legacy Next.js backend API
        try {
          await MasterAdminApiClient.post(
            MasterAdminEndpoints.companyApproval(item.id),
            {'action': 'approve', 'status': 'approved'},
          );
        } catch (_) {}

        // 6. Refresh CompanyManagementStore immediately in-memory
        try {
          CompanyManagementStore.instance.updateCompanyStatusLocally(item.id, 'Active');
          if (item.title.isNotEmpty) {
            CompanyManagementStore.instance.updateCompanyStatusLocally(item.title, 'Active');
          }
          CompanyManagementStore.instance.loadGlobalCompanies();
        } catch (_) {}

        _pendingItems.removeWhere((i) => i.id == item.id);
        notifyListeners();
        return true;
      } else if (item.rawJoinRequest != null) {
        return await approveRequest(item.rawJoinRequest!);
      }
      return false;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] approveItem error: $e');
      return false;
    }
  }

  /// Reject an item (either Enterprise company or Join Request)
  Future<bool> rejectItem(MasterApprovalItem item, {String? reason}) async {
    markLocallyResolved(item.id, title: item.title);
    try {
      if (item.type == 'company') {
        // Mark enterprise as rejected / suspended in Firestore
        try {
          await _firestore.collection('enterprises').doc(item.id).set({
            'approvalStatus': 'rejected',
            'status': 'Suspended',
            'isSuspended': true,
            'rejectionReason': reason ?? 'Declined by Master Admin.',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        try {
          final entByName = await _firestore.collection('enterprises').where('companyName', isEqualTo: item.title).get();
          for (final doc in entByName.docs) {
            await doc.reference.set({
              'approvalStatus': 'rejected',
              'status': 'Suspended',
              'isSuspended': true,
              'rejectionReason': reason ?? 'Declined by Master Admin.',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}

        try {
          await _firestore.collection('companies').doc(item.id).set({
            'approvalStatus': 'rejected',
            'status': 'suspended',
            'isSuspended': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        try {
          final compByName = await _firestore.collection('companies').where('companyName', isEqualTo: item.title).get();
          for (final doc in compByName.docs) {
            await doc.reference.set({
              'approvalStatus': 'rejected',
              'status': 'suspended',
              'isSuspended': true,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}

        try {
          await _firestore.collection('users').doc(item.id).set({
            'approvalStatus': 'rejected',
            'status': 'suspended',
            'isSuspended': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}

        // Cascade rejection to any users tied to this company
        try {
          final usersSnap = await _firestore
              .collection('users')
              .where('companyId', isEqualTo: item.id)
              .get();
          for (final doc in usersSnap.docs) {
            await doc.reference.set({
              'approvalStatus': 'rejected',
              'status': 'suspended',
              'isSuspended': true,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          final usersByTitle = await _firestore
              .collection('users')
              .where('companyName', isEqualTo: item.title)
              .get();
          for (final doc in usersByTitle.docs) {
            await doc.reference.set({
              'approvalStatus': 'rejected',
              'status': 'suspended',
              'isSuspended': true,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (e) {
          debugPrint('[ApprovalsQueueStore] Error cascading user rejection: $e');
        }

        // Immediately update CompanyManagementStore in memory
        CompanyManagementStore.instance.updateCompanyStatusLocally(item.id, 'Suspended');
        if (item.title.isNotEmpty) {
          CompanyManagementStore.instance.updateCompanyStatusLocally(item.title, 'Suspended');
        }

        // Notify Next.js live backend sync API
        try {
          await MasterApprovalSyncService.approveCompany(
            companyId: item.id,
            action: 'reject',
            reason: reason,
          );
        } catch (apiErr) {
          debugPrint('[ApprovalsQueueStore] MasterApprovalSyncService reject error: $apiErr');
        }

        try {
          await MasterAdminApiClient.post(
            MasterAdminEndpoints.companyApproval(item.id),
            {'action': 'reject', 'status': 'rejected', 'reason': reason},
          );
        } catch (_) {}

        _pendingItems.removeWhere((i) => i.id == item.id || i.title.toLowerCase().trim() == item.title.toLowerCase().trim());
        notifyListeners();
        return true;
      } else if (item.rawJoinRequest != null) {
        return await rejectRequest(item.rawJoinRequest!, reason: reason);
      }
      return false;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] rejectItem error: $e');
      return false;
    }
  }

  /// Approve a pending join request
  Future<bool> approveRequest(EnterpriseJoinRequestModel request) async {
    try {
      final ok = await EnterpriseRequestFetchService.instance.approveJoinRequest(request: request);
      if (ok) {
        await MasterAdminApiClient.post(
          MasterAdminEndpoints.companyApproval(request.id),
          {'status': 'approved'},
        );
        _pendingItems.removeWhere((item) => item.id == request.id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] approveRequest error: $e');
      return false;
    }
  }

  /// Reject a pending join request
  Future<bool> rejectRequest(EnterpriseJoinRequestModel request, {String? reason}) async {
    try {
      final ok = await EnterpriseRequestFetchService.instance.rejectJoinRequest(
        request: request,
        reason: reason ?? 'Request declined by Master Admin.',
      );
      if (ok) {
        _pendingItems.removeWhere((item) => item.id == request.id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('[ApprovalsQueueStore] rejectRequest error: $e');
      return false;
    }
  }
}

