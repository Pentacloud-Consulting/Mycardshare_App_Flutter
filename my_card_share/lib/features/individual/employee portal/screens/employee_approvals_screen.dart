import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../auth/font style/font_style.dart';
import 'approvals/approvals_stat_chips_section.dart';
import 'approvals/approvals_list_section.dart';
import 'approvals/approvals_new_request_button.dart';

class EmployeeApprovalsScreen extends StatefulWidget {
  const EmployeeApprovalsScreen({super.key});

  @override
  State<EmployeeApprovalsScreen> createState() => _EmployeeApprovalsScreenState();
}

class _EmployeeApprovalsScreenState extends State<EmployeeApprovalsScreen> {
  final List<ApprovalRequestItem> _requests = [
    const ApprovalRequestItem(
      id: 'req-1',
      type: 'Job Title Change',
      submittedTime: '2 days ago',
      fromValue: 'Sales Associate',
      toValue: 'Senior Sales Associate',
      status: 'Pending',
    ),
    const ApprovalRequestItem(
      id: 'req-2',
      type: 'Corporate Voucher Claim',
      submittedTime: '5 days ago',
      fromValue: 'Standard Free Member',
      toValue: 'Enterprise Pro (PROMO2026)',
      status: 'Approved',
      adminNote: 'Approved by Priya Sharma (VP Operations)',
    ),
    const ApprovalRequestItem(
      id: 'req-3',
      type: 'Custom Theme Color',
      submittedTime: '1 week ago',
      fromValue: 'Navy #0F172A',
      toValue: 'Crimson #DC2626',
      status: 'Rejected',
      adminNote: 'Conflicts with Acme Realty corporate brand guide',
    ),
  ];

  void _showNewRequestDialog() {
    final typeController = TextEditingController(text: "Job Title Change");
    final fromController = TextEditingController();
    final toController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "New Change Request",
                    style: AppFontStyle.headlineMedium.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Request Type",
                style: AppFontStyle.titleMedium.copyWith(fontSize: 13, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: typeController,
                style: TextStyle(fontFamily: AppFontStyle.fontFamily),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Current Value (From)",
                style: AppFontStyle.titleMedium.copyWith(fontSize: 13, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: fromController,
                style: TextStyle(fontFamily: AppFontStyle.fontFamily),
                decoration: InputDecoration(
                  hintText: "e.g. Sales Associate",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Requested Value (To)",
                style: AppFontStyle.titleMedium.copyWith(fontSize: 13, color: const Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: toController,
                style: TextStyle(fontFamily: AppFontStyle.fontFamily),
                decoration: InputDecoration(
                  hintText: "e.g. Senior Sales Associate",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () {
                  if (typeController.text.trim().isNotEmpty &&
                      toController.text.trim().isNotEmpty) {
                    setState(() {
                      _requests.insert(
                        0,
                        ApprovalRequestItem(
                          id: 'req-${DateTime.now().millisecondsSinceEpoch}',
                          type: typeController.text.trim(),
                          submittedTime: 'Just now',
                          fromValue: fromController.text.trim().isNotEmpty
                              ? fromController.text.trim()
                              : 'Current Field Value',
                          toValue: toController.text.trim(),
                          status: 'Pending',
                        ),
                      );
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("New change request submitted to company admin!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      "Submit Change Request",
                      style: AppFontStyle.buttonText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _requests.where((r) => r.status == "Pending").length;
    final approvedCount = _requests.where((r) => r.status == "Approved").length;
    final rejectedCount = _requests.where((r) => r.status == "Rejected").length;

    return SmartPopScope(
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/portal');
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Soft baby-blue gradient blob top-right corner
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFDBEAFE).withValues(alpha: 0.75),
                      const Color(0xFFEFF6FF).withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small gray subtext
                    Text(
                      "Company card approval requests",
                      style: AppFontStyle.bodyMedium.copyWith(fontSize: 13),
                    ),

                    const SizedBox(height: 14),

                    // 3 Stat Chips Row
                    ApprovalsStatChipsSection(
                      pendingCount: pendingCount,
                      approvedCount: approvedCount,
                      rejectedCount: rejectedCount,
                    ),

                    const SizedBox(height: 16),

                    // Requests List
                    ApprovalsListSection(
                      requests: _requests,
                      onItemTap: (item) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Details for request: ${item.type}"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // New Change Request Button
                    ApprovalsNewRequestButton(
                      onTap: _showNewRequestDialog,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
