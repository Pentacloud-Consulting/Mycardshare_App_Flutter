import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../backend/master_admin/companies/company_management_store.dart';
import '../../../backend/master_admin/companies/models/master_company_model.dart';
import '../../../backend/master_admin/approvals/approvals_queue_store.dart';
import '../../../backend/enterprise/profile/enterprise_profile_store.dart';
import 'widgets/company_detail_header.dart';
import 'widgets/company_detail_stats_grid.dart';
import 'widgets/company_detail_team_section.dart';
import 'widgets/company_detail_subscription_card.dart';
import 'widgets/company_detail_admin_contact.dart';
import 'widgets/company_detail_danger_zone.dart';

class MasterAdminCompanyDetailScreen extends StatefulWidget {
  final String? companyId;

  const MasterAdminCompanyDetailScreen({
    super.key,
    this.companyId,
  });

  @override
  State<MasterAdminCompanyDetailScreen> createState() => _MasterAdminCompanyDetailScreenState();
}

class _MasterAdminCompanyDetailScreenState extends State<MasterAdminCompanyDetailScreen> {
  bool _isApproving = false;
  bool _isRejecting = false;
  bool _isDeleting = false;

  Future<void> _handleApprove({
    required String companyId,
    required String companyName,
    required String adminEmail,
  }) async {
    setState(() => _isApproving = true);

    try {
      final item = MasterApprovalItem(
        id: companyId,
        title: companyName,
        email: adminEmail,
        type: 'company',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final ok = await ApprovalsQueueStore.instance.approveItem(item);

      if (ok) {
        CompanyManagementStore.instance.updateCompanyStatusLocally(companyId, 'Active');
        if (companyName.isNotEmpty) {
          CompanyManagementStore.instance.updateCompanyStatusLocally(companyName, 'Active');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  ok ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ok
                        ? "Organization '$companyName' approved successfully! Team can now log in."
                        : "Failed to approve organization. Please check network connection.",
                  ),
                ),
              ],
            ),
            backgroundColor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApproving = false);
      }
    }
  }

  Future<void> _handleReject({
    required String companyId,
    required String companyName,
    required String adminEmail,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Decline Organization Request?"),
        content: Text("Are you sure you want to decline registration for '$companyName'? This will prevent the admin from logging in."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text("Decline", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRejecting = true);
    try {
      final item = MasterApprovalItem(
        id: companyId,
        title: companyName,
        email: adminEmail,
        type: 'company',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final ok = await ApprovalsQueueStore.instance.rejectItem(item);

      if (ok) {
        CompanyManagementStore.instance.updateCompanyStatusLocally(companyId, 'Suspended');
        if (companyName.isNotEmpty) {
          CompanyManagementStore.instance.updateCompanyStatusLocally(companyName, 'Suspended');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? "Registration for '$companyName' was declined."
                  : "Failed to decline organization.",
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  Future<void> _handleDeleteCompany({
    required String companyId,
    required String companyName,
    required String adminEmail,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 8),
            Text("Delete Company?", style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          "Are you sure you want to permanently delete '$companyName'?\n\nAll company cards, workforce accounts, and employee login access will be permanently revoked. This action cannot be undone.",
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete Permanently", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final ok = await CompanyManagementStore.instance.deleteCompanyPermanently(
        companyId: companyId,
        companyName: companyName,
        adminEmail: adminEmail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ok
                        ? "Company '$companyName' has been permanently deleted."
                        : "Failed to delete company. Please check connection.",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: ok ? const Color(0xFF0F172A) : const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        if (ok) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/master-admin/companies');
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Resolve effective company ID: from route param, or active EnterpriseProfileStore, or default
    final activeProfile = EnterpriseProfileStore.instance.currentProfile;
    final effectiveId = (widget.companyId != null && widget.companyId!.isNotEmpty && widget.companyId != 'acme_realty')
        ? widget.companyId!
        : (activeProfile?.uid ?? 'acme_realty');

    final cachedCompany = CompanyManagementStore.instance.companies
        .where((c) => c.id == effectiveId)
        .firstOrNull;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('enterprises').doc(effectiveId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        
        // Priority: Firestore enterprises doc -> cached company -> active EnterpriseProfileStore -> fallback
        final companyName = (data['companyName'] as String?)?.trim().isNotEmpty == true
            ? (data['companyName'] as String)
            : ((data['name'] as String?)?.trim().isNotEmpty == true
                ? (data['name'] as String)
                : (cachedCompany?.name.trim().isNotEmpty == true
                    ? cachedCompany!.name
                    : (activeProfile?.companyName.trim().isNotEmpty == true
                        ? activeProfile!.companyName
                        : 'Enterprise')));

        final logoUrl = (data['logoUrl'] as String?)?.trim().isNotEmpty == true
            ? (data['logoUrl'] as String)
            : ((data['companyLogo'] as String?)?.trim().isNotEmpty == true
                ? (data['companyLogo'] as String)
                : (cachedCompany?.logoUrl ?? activeProfile?.logoUrl));

        final planName = data['planName'] ?? data['plan'] ?? (cachedCompany?.plan.isNotEmpty == true ? cachedCompany!.plan : (activeProfile?.plan.isNotEmpty == true ? activeProfile!.plan : 'Enterprise Pro'));
        
        final firestoreApproval = (data['approvalStatus'] as String? ?? '').toLowerCase().trim();
        final firestoreStatus = (data['status'] as String? ?? '').toLowerCase().trim();
        final cachedStatus = (cachedCompany?.status ?? '').toLowerCase().trim();

        // If explicitly approved or active, it is NOT pending
        final isApproved = firestoreApproval == 'approved' ||
            firestoreStatus == 'active' ||
            (firestoreApproval != 'pending' && firestoreStatus != 'pending' && cachedStatus == 'active');

        final isSuspended = data['isSuspended'] == true ||
            firestoreStatus == 'suspended' ||
            firestoreApproval == 'rejected' ||
            cachedStatus == 'suspended';

        final isPending = !isApproved && !isSuspended && (
          firestoreApproval == 'pending' ||
          firestoreStatus == 'pending' ||
          (cachedStatus == 'pending' && firestoreApproval.isEmpty && firestoreStatus.isEmpty)
        );

        final statusText = isSuspended
            ? 'Suspended'
            : (isApproved
                ? 'Active'
                : (isPending
                    ? 'Pending'
                    : (firestoreStatus.isNotEmpty ? firestoreStatus.capitalizeFirst() : 'Active')));

        final sinceText = data['createdAt'] != null
            ? "Since ${(data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate().year : '2026')}"
            : (cachedCompany?.createdAt != null
                ? "Since ${cachedCompany!.createdAt!.year}"
                : "Since Jan 2026");

        final employeeCount = (data['employeeCount'] as num?)?.toInt() ?? (cachedCompany?.employeeCount ?? (activeProfile?.employeeCount ?? 1));
        final employeeLimit = (data['employeeLimit'] as num?)?.toInt() ?? 50;
        final totalLeads = (data['totalLeads'] ?? '0').toString();
        final cardViews = (data['cardViews'] ?? '0').toString();
        final planValue = data['planValue'] ?? '\$299/mo';
        final adminName = data['adminName'] ?? data['contactName'] ?? 'Admin Contact';
        final adminEmail = data['email'] ?? data['adminEmail'] ?? (cachedCompany?.email.isNotEmpty == true ? cachedCompany!.email : (activeProfile?.email.isNotEmpty == true ? activeProfile!.email : 'admin@company.com'));
        final adminPhone = data['phone'] ?? data['adminPhone'] ?? (activeProfile?.phoneNumber.isNotEmpty == true ? activeProfile!.phoneNumber : '+1 (555) 000-0000');
        final expiryDate = data['subscriptionExpiry'] ?? 'Expires: Dec 31, 2027';

        final initials = () {
          final clean = companyName.trim();
          if (clean.isEmpty) return 'CO';
          final parts = clean.split(RegExp(r'\s+'));
          if (parts.length == 1) {
            return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
          }
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }();

        final adminInitials = () {
          final clean = adminName.trim();
          if (clean.isEmpty) return 'AD';
          final parts = clean.split(RegExp(r'\s+'));
          if (parts.length == 1) {
            return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
          }
          return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        }();

        return Stack(
          children: [
            // Background Top-Right Ambient Soft Baby-Blue Gradient Blob
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.22),
                      const Color(0xFF0052FF).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Company Detail Content Area
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Card (Real Data & Real Logo)
                  CompanyDetailHeader(
                    companyName: companyName,
                    planName: planName,
                    statusText: statusText,
                    sinceText: sinceText,
                    logoInitials: initials,
                    logoUrl: logoUrl,
                  ),

                  // ⚡ 1b. Prominent Master Admin Quick-Approve Banner for Pending Organizations
                  if (isPending) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD97706).withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: const Icon(
                                  Icons.pending_actions_rounded,
                                  color: Color(0xFFD97706),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Action Required: Organization Pending",
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "This account is awaiting Master Admin approval to unlock team login.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: (_isApproving || _isRejecting)
                                      ? null
                                      : () => _handleApprove(
                                            companyId: effectiveId,
                                            companyName: companyName,
                                            adminEmail: adminEmail,
                                          ),
                                  icon: _isApproving
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                  label: Text(
                                    _isApproving ? "Approving..." : "Approve Organization",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: (_isApproving || _isRejecting)
                                      ? null
                                      : () => _handleReject(
                                            companyId: effectiveId,
                                            companyName: companyName,
                                            adminEmail: adminEmail,
                                          ),
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 18),
                                  label: Text(
                                    _isRejecting ? "Declining..." : "Decline",
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // 2. 2x2 Stat Tiles Grid (Real Data)
                  CompanyDetailStatsGrid(
                    activeEmployees: employeeCount,
                    maxEmployees: employeeLimit,
                    totalLeads: totalLeads,
                    cardViews: cardViews,
                    planValue: planValue,
                  ),

                  const SizedBox(height: 22),

                  // 3. Team Members Section (Above Subscription - shows all employees with logos & roles)
                  CompanyDetailTeamSection(
                    companyId: effectiveId,
                  ),

                  const SizedBox(height: 22),

                  // 4. Subscription Section (Real Plan)
                  CompanyDetailSubscriptionCard(
                    planName: planName,
                    expiryDate: expiryDate,
                  ),

                  const SizedBox(height: 22),

                  // 4. Admin Contact Section (Real Data)
                  CompanyDetailAdminContact(
                    adminName: adminName,
                    adminEmail: adminEmail,
                    adminPhone: adminPhone,
                    avatarInitials: adminInitials,
                  ),

                  const SizedBox(height: 24),

                  // 5. Danger Zone (Suspend Company & Delete Company buttons with real actions)
                  CompanyDetailDangerZone(
                    isSuspended: statusText.toLowerCase() == 'suspended',
                    onSuspend: () async {
                      final isCurrentlySuspended = statusText.toLowerCase() == 'suspended';
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(
                                isCurrentlySuspended ? Icons.play_circle_fill_rounded : Icons.pause_circle_filled_rounded,
                                color: isCurrentlySuspended ? const Color(0xFF10B981) : const Color(0xFFD97706),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCurrentlySuspended ? "Reactivate Company?" : "Suspend Company?",
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          content: Text(
                            isCurrentlySuspended
                                ? "Are you sure you want to reactivate '$companyName'? Team members will regain full workspace and digital card access."
                                : "Are you sure you want to suspend '$companyName'? All team members will be temporarily locked out until reactivated.",
                            style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5, height: 1.4),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrentlySuspended ? const Color(0xFF10B981) : const Color(0xFFD97706),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(
                                isCurrentlySuspended ? "Reactivate Workspace" : "Suspend Workspace",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      final ok = await CompanyManagementStore.instance.toggleSuspendCompany(
                        effectiveId,
                        !isCurrentlySuspended,
                        companyName: companyName,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok
                                ? "Company '$companyName' ${isCurrentlySuspended ? 'reactivated' : 'suspended'} successfully"
                                : "Failed to update company status"),
                            backgroundColor: ok ? const Color(0xFF10B981) : Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    onDelete: _isDeleting
                        ? null
                        : () => _handleDeleteCompany(
                              companyId: effectiveId,
                              companyName: companyName,
                              adminEmail: adminEmail,
                            ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
