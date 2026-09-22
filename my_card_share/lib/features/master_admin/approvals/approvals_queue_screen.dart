import 'package:flutter/material.dart';

import 'widgets/approvals_summary_banner.dart';
import 'widgets/approval_card_list.dart';

class MasterAdminApprovalScreen extends StatelessWidget {
  const MasterAdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            children: const [
              // 1. Amber-tinted Summary Banner
              ApprovalsSummaryBanner(
                pendingCount: 6,
                avgWaitTime: "4 hours",
              ),

              SizedBox(height: 18),

              // 2. Vertical list of approval request cards
              ApprovalCardList(),

              SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
