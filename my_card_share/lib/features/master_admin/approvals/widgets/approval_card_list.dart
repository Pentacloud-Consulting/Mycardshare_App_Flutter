import 'package:flutter/material.dart';

class ApprovalCardList extends StatefulWidget {
  const ApprovalCardList({super.key});

  @override
  State<ApprovalCardList> createState() => _ApprovalCardListState();
}

class _ApprovalCardListState extends State<ApprovalCardList> {
  final List<Map<String, dynamic>> _approvalRequests = [
    {
      'id': 'appr-1',
      'companyName': 'Skyline Brokers',
      'logoText': 'SB',
      'logoBg': const Color(0xFF0052FF),
      'requestedTime': '2h ago',
      'planTag': 'Enterprise',
      'adminName': 'Priya Sharma',
      'adminEmail': 'priya@skylinebrokers.com',
      'employeesRequested': '12 requested',
      'voucher': 'None',
      'planName': 'Enterprise Pro',
    },
    {
      'id': 'appr-2',
      'companyName': 'Vertex Media Group',
      'logoText': 'VM',
      'logoBg': const Color(0xFF8B5CF6),
      'requestedTime': '4h ago',
      'planTag': 'Enterprise',
      'adminName': 'Marcus Vance',
      'adminEmail': 'marcus@vertexmedia.io',
      'employeesRequested': '25 requested',
      'voucher': 'PROMO2026',
      'planName': 'Enterprise Pro',
    },
    {
      'id': 'appr-3',
      'companyName': 'Crestview Capital',
      'logoText': 'CC',
      'logoBg': const Color(0xFF0D9488),
      'requestedTime': '6h ago',
      'planTag': 'Enterprise',
      'adminName': 'Elena Rostova',
      'adminEmail': 'elena@crestviewcap.com',
      'employeesRequested': '8 requested',
      'voucher': 'None',
      'planName': 'Enterprise Standard',
    },
  ];

  void _handleApprove(String companyName, int index) {
    setState(() {
      _approvalRequests.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text("$companyName approved successfully!")),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleReject(String companyName, int index) {
    setState(() {
      _approvalRequests.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text("$companyName registration rejected.")),
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
    if (_approvalRequests.isEmpty) {
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
        child: Column(
          children: const [
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
      children: _approvalRequests.asMap().entries.map((entry) {
        final index = entry.key;
        final req = entry.value;

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
              // TOP ROW: Logo Circle (left) + Name & Time + Plan Tag Pill (top-right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (req['logoBg'] as Color).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (req['logoBg'] as Color).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        req['logoText'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: req['logoBg'] as Color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req['companyName'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Requested ${req['requestedTime']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      req['planTag'] as String,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0052FF),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // MIDDLE: 2-COLUMN MINI INFO GRID INSIDE CARD
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
                        // Left Col: Admin Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'sans-serif'),
                                  children: [
                                    const TextSpan(text: "Admin: ", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                    TextSpan(text: req['adminName'] as String, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                req['adminEmail'] as String,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Right Col: Employees Info
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'sans-serif'),
                              children: [
                                const TextSpan(text: "Employees: ", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                TextSpan(text: req['employeesRequested'] as String, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Col: Voucher Info
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'sans-serif'),
                              children: [
                                const TextSpan(text: "Voucher: ", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                TextSpan(
                                  text: req['voucher'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: req['voucher'] != 'None' ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Right Col: Plan Info
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'sans-serif'),
                              children: [
                                const TextSpan(text: "Plan: ", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                TextSpan(text: req['planName'] as String, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
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

              // BOTTOM OF CARD: 2 SIDE-BY-SIDE SPLIT BUTTONS
              Row(
                children: [
                  // Reject Button (Outlined Red)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleReject(req['companyName'] as String, index),
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

                  // Approve Button (Filled Green)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _handleApprove(req['companyName'] as String, index),
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
  }
}
