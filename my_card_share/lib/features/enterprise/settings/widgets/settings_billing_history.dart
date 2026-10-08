import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/settings/billing_history.dart';

/// Opens the full Billing History Screen for viewing past enterprise workspace invoices.
Future<void> showBillingHistoryPage(BuildContext context, {String? uid}) async {
  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      builder: (ctx) => EnterpriseBillingHistoryScreen(uid: uid),
    ),
  );
}

/// Frontend Row Widget for Billing History in Settings list.
class SettingsBillingHistoryRow extends StatelessWidget {
  final VoidCallback? onTap;
  final String? uid;

  const SettingsBillingHistoryRow({
    super.key,
    this.onTap,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => showBillingHistoryPage(context, uid: uid),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            // Soft Purple Rounded Square with Receipt Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF7C3AED),
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Billing History",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen Page displaying real historical billing statements and invoice receipts.
class EnterpriseBillingHistoryScreen extends StatelessWidget {
  final String? uid;

  const EnterpriseBillingHistoryScreen({
    super.key,
    this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Clean Custom Top Nav Bar (Fixes Image 2 Double Nav) ─────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Billing History",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── 2. Top Current Plan Real Summary Card (Fixes Image 1 Overflow) ─
              StreamBuilder<EnterpriseBillingSummaryData>(
                stream: EnterpriseBillingHistoryService.instance.streamBillingSummary(targetUid),
                builder: (context, summarySnap) {
                  final summary = summarySnap.data ??
                      EnterpriseBillingSummaryData.fromFirestore(null);

                  final subText = summary.paymentMethod.isNotEmpty
                      ? "${summary.billingCycle} · ${summary.paymentMethod}"
                      : summary.billingCycle;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Award Icon
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Color(0xFFD97706),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Expanded Center Column (Prevents Right Overflow - Image 1)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                summary.planName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Status Badge Tag (Active)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: summary.status.toLowerCase() == 'active'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            summary.status,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: summary.status.toLowerCase() == 'active'
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── 3. Invoices Section Header ─────────────────────────────────
              const Text(
                "Past Statements & Receipts",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Official statements and payment receipts for accounting & tax purposes.",
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),

              const SizedBox(height: 14),

              // ── 4. Real Invoices Stream (No Mock Data) ─────────────────────
              StreamBuilder<List<BillingInvoiceModel>>(
                stream: EnterpriseBillingHistoryService.instance.streamInvoices(targetUid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                      ),
                    );
                  }

                  final invoices = snapshot.data ?? [];

                  // Clean Empty State when no real invoices exist in Firestore
                  if (invoices.isEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3E8FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 26,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "No Invoices Found",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Past subscription payments and invoice receipts for your workspace will be listed here automatically.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Render Real Invoices
                  return Column(
                    children: invoices.map((inv) {
                      final dateStr =
                          "${_getMonthName(inv.date.month)} ${inv.date.day}, ${inv.date.year}";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Color(0xFF7C3AED),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        inv.id,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          inv.status,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF16A34A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "$dateStr · ${inv.planName}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  inv.formattedAmount,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => EnterpriseBillingHistoryService.instance
                                      .downloadInvoiceReceipt(context, inv),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.download_rounded,
                                          size: 14, color: Color(0xFF7C3AED)),
                                      SizedBox(width: 2),
                                      Text(
                                        "Receipt",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF7C3AED),
                                        ),
                                      ),
                                    ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[(month - 1).clamp(0, 11)];
  }
}
