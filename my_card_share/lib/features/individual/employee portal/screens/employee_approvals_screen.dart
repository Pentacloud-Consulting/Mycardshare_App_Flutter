import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../auth/font style/font_style.dart';
import '../../../../backend/employee_join/home/employee_home_backend.dart';
import 'approvals/approvals_stat_chips_section.dart';
import 'approvals/approvals_list_section.dart';
import 'approvals/approvals_new_request_button.dart';

class EmployeeApprovalsScreen extends StatefulWidget {
  const EmployeeApprovalsScreen({super.key});

  @override
  State<EmployeeApprovalsScreen> createState() => _EmployeeApprovalsScreenState();
}

class _EmployeeApprovalsScreenState extends State<EmployeeApprovalsScreen> {
  List<ApprovalRequestItem> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  Future<void> _loadApprovals() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('approval_requests')
          .get();

      if (mounted) {
        setState(() {
          _requests = snap.docs.map((d) {
            final data = d.data();
            return ApprovalRequestItem(
              id: d.id,
              type: data['type'] as String? ?? 'Change Request',
              submittedTime: data['submittedTime'] as String? ?? 'Recently',
              fromValue: data['fromValue'] as String? ?? '-',
              toValue: data['toValue'] as String? ?? '-',
              status: data['status'] as String? ?? 'Pending',
              adminNote: data['adminNote'] as String?,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitRequest(String type, String fromVal, String toVal) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final entUid = EmployeeHomeBackendService.instance.enterpriseUid;
    final newReq = ApprovalRequestItem(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      submittedTime: 'Just now',
      fromValue: fromVal.isNotEmpty ? fromVal : 'Current Field Value',
      toValue: toVal,
      status: 'Pending',
    );

    setState(() {
      _requests.insert(0, newReq);
    });

    if (uid != null) {
      final reqMap = {
        'id': newReq.id,
        'userId': uid,
        'enterpriseUid': entUid,
        'type': type,
        'fromValue': newReq.fromValue,
        'toValue': toVal,
        'status': 'Pending',
        'submittedTime': 'Just now',
        'createdAt': FieldValue.serverTimestamp(),
      };
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('approval_requests')
            .doc(newReq.id)
            .set(reqMap);

        if (entUid != null && entUid.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('enterprises')
              .doc(entUid)
              .collection('approvals')
              .doc(newReq.id)
              .set(reqMap);
        }
      } catch (e) {
        debugPrint('[EmployeeApprovals] Error saving request: $e');
      }
    }
  }

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
                    _submitRequest(
                      typeController.text.trim(),
                      fromController.text.trim(),
                      toController.text.trim(),
                    );
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


