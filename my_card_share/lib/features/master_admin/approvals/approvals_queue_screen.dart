import 'package:flutter/material.dart';
import '../../../backend/master_admin/approvals/approvals_queue_store.dart';
import 'widgets/approvals_summary_banner.dart';
import 'widgets/approval_card_list.dart';

class MasterAdminApprovalScreen extends StatelessWidget {
  const MasterAdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ApprovalsQueueStore.instance,
      builder: (context, _) {
        return StreamBuilder<int>(
          stream: ApprovalsQueueStore.instance.streamPendingQueue().map((l) => l.length),
          builder: (context, snapshot) {
            final count = snapshot.hasData
                ? snapshot.data!
                : ApprovalsQueueStore.instance.pendingCount;

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

            // Main Pending Approvals Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Amber-tinted Summary Banner with Real Live Count
                  ApprovalsSummaryBanner(
                    pendingCount: count,
                    avgWaitTime: "< 2 hours",
                  ),

                  const SizedBox(height: 18),

                  // 2. Vertical list of approval request cards (Real Firestore stream)
                  const ApprovalCardList(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
          );
        },
      );
    },
  );
}
}



