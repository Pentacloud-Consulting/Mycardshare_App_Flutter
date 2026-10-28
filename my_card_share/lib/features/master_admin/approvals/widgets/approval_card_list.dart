import 'package:flutter/material.dart';
import '../../../../backend/master_admin/approvals/approvals_queue_store.dart';
import '../../companies/widgets/company_logo_avatar.dart';

class ApprovalCardList extends StatelessWidget {
  const ApprovalCardList({super.key});

  Future<void> _handleApprove(BuildContext context, MasterApprovalItem item) async {
    // ⚡ CRITICAL: Optimistically remove from local pending list immediately!
    ApprovalsQueueStore.instance.markLocallyResolved(item.id);

    final messenger = ScaffoldMessenger.of(context);
    final ok = await ApprovalsQueueStore.instance.approveItem(item);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(ok
                  ? "${item.title} (${item.email}) approved successfully!"
                  : "Approval failed. Please check connection."),
            ),
          ],
        ),
        backgroundColor: ok ? const Color(0xFF10B981) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleReject(BuildContext context, MasterApprovalItem item) async {
    // ⚡ CRITICAL: Optimistically remove from local pending list immediately!
    ApprovalsQueueStore.instance.markLocallyResolved(item.id);

    final messenger = ScaffoldMessenger.of(context);
    final ok = await ApprovalsQueueStore.instance.rejectItem(item);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(ok
                  ? "Request for ${item.title} was declined."
                  : "Failed to decline request."),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ApprovalsQueueStore.instance,
      builder: (context, _) {
        return StreamBuilder<List<MasterApprovalItem>>(
          stream: ApprovalsQueueStore.instance.streamPendingQueue(),
          builder: (context, snapshot) {
            final allRequests = snapshot.data ?? ApprovalsQueueStore.instance.pendingItems;
            final requests = allRequests.where((i) => !ApprovalsQueueStore.instance.isResolved(i.id)).toList();

        if (snapshot.connectionState == ConnectionState.waiting && requests.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }

        if (requests.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 48),
                SizedBox(height: 12),
                Text(
                  "All Approvals Cleared!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "No pending company approval requests right now.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: requests.map((req) {
            final initials = req.initials;
            final isCompany = req.type == 'company';

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP ROW: Logo Circle + Name & Time + Tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompanyLogoAvatar(
                        logoUrl: req.logoUrl,
                        companyName: req.title,
                        domain: req.domain,
                        size: 44,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req.title.isNotEmpty ? req.title : (isCompany ? "Pending Enterprise" : "Join Request"),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isCompany
                                  ? (req.domain != null && req.domain!.isNotEmpty ? "Domain: ${req.domain}" : req.email)
                                  : "Target: ${req.targetCompany}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompany ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCompany ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Text(
                          isCompany ? "New Company" : "Employee Join",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isCompany ? const Color(0xFF0052FF) : const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // MIDDLE: 2-COLUMN INFO GRID
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'sans-serif'),
                                      children: [
                                        TextSpan(text: isCompany ? "Admin Email: " : "User Email: ", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                        TextSpan(text: req.email, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'sans-serif'),
                                  children: [
                                    const TextSpan(text: "Status: ", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                    TextSpan(text: req.status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BOTTOM OF CARD: APPROVE / REJECT BUTTONS
                  Row(
                    children: [
                      // Reject Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleReject(context, req),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "❌ Reject",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Approve Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleApprove(context, req),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "✅ Approve",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          );
        },
      );
    },
  );
}
}




