import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/enterprise_profile_store.dart';

/// Data model representing a real Enterprise billing invoice record from Firestore.
class BillingInvoiceModel {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String planName;
  final int seatsCount;
  final DateTime date;
  final String paymentMethod;
  final String? pdfUrl;

  const BillingInvoiceModel({
    required this.id,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    required this.planName,
    required this.seatsCount,
    required this.date,
    this.paymentMethod = '',
    this.pdfUrl,
  });

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  factory BillingInvoiceModel.fromFirestore(String id, Map<String, dynamic> data) {
    return BillingInvoiceModel(
      id: id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] as String? ?? 'USD',
      status: data['status'] as String? ?? 'Paid',
      planName: data['planName'] as String? ?? 'Workspace Plan',
      seatsCount: (data['seatsCount'] as num?)?.toInt() ?? 1,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: data['paymentMethod'] as String? ?? '',
      pdfUrl: data['pdfUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'currency': currency,
        'status': status,
        'planName': planName,
        'seatsCount': seatsCount,
        'date': Timestamp.fromDate(date),
        'paymentMethod': paymentMethod,
        'pdfUrl': pdfUrl,
      };
}

/// Real Billing Subscription Summary Data Model.
class EnterpriseBillingSummaryData {
  final String planName;
  final String billingCycle;
  final String paymentMethod;
  final String status;

  const EnterpriseBillingSummaryData({
    required this.planName,
    required this.billingCycle,
    required this.paymentMethod,
    required this.status,
  });

  factory EnterpriseBillingSummaryData.fromFirestore(Map<String, dynamic>? data) {
    final profile = EnterpriseProfileStore.instance.currentProfile;
    final rawPlan = data?['planName'] as String? ?? data?['plan'] as String? ?? profile?.plan ?? 'Free';
    final capitalized = rawPlan.isEmpty
        ? 'Free'
        : (rawPlan[0].toUpperCase() + rawPlan.substring(1));
    final planStr = capitalized.toLowerCase().contains('plan')
        ? capitalized
        : '$capitalized Plan';

    final cycle = data?['billingCycle'] as String? ?? (data?['billingPeriod'] as String?) ?? 'Monthly';
    final payment = data?['paymentMethod'] as String? ?? '';
    final status = data?['subscriptionStatus'] as String? ?? data?['status'] as String? ?? 'Active';

    return EnterpriseBillingSummaryData(
      planName: planStr,
      billingCycle: cycle,
      paymentMethod: payment,
      status: status,
    );
  }
}

/// Service managing real enterprise billing history and invoice streaming from Firestore.
class EnterpriseBillingHistoryService {
  EnterpriseBillingHistoryService._internal();
  static final EnterpriseBillingHistoryService instance =
      EnterpriseBillingHistoryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Streams real billing summary info for enterprise from `enterprises/{uid}`.
  Stream<EnterpriseBillingSummaryData> streamBillingSummary([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(EnterpriseBillingSummaryData.fromFirestore(null));
    }

    return _firestore.collection('enterprises').doc(targetUid).snapshots().map((doc) {
      return EnterpriseBillingSummaryData.fromFirestore(doc.data());
    });
  }

  /// Streams real enterprise billing invoices from `enterprises/{uid}/invoices`.
  /// Returns empty list if no real invoices exist in Firestore. No mock data generated.
  Stream<List<BillingInvoiceModel>> streamInvoices([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('invoices')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) {
        return const [];
      }

      return snap.docs
          .map((doc) => BillingInvoiceModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Copies real invoice receipt info to clipboard with toast notification.
  void downloadInvoiceReceipt(BuildContext context, BillingInvoiceModel invoice) {
    final receiptText =
        "Invoice #${invoice.id} (${invoice.planName} - ${invoice.formattedAmount}) Receipt";
    Clipboard.setData(ClipboardData(text: receiptText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.file_download_done_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text("Invoice #${invoice.id} receipt details copied!"),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
