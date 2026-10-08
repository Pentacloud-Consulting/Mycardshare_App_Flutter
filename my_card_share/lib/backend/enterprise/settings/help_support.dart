import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/enterprise_profile_store.dart';

/// Data Model for an Enterprise Support Ticket in Firestore.
class SupportTicketModel {
  final String id;
  final String subject;
  final String category;
  final String message;
  final String status; // 'Open', 'In Progress', 'Resolved'
  final String priority; // 'Normal', 'High', 'Urgent'
  final DateTime createdAt;

  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.message,
    required this.status,
    this.priority = 'Normal',
    required this.createdAt,
  });

  factory SupportTicketModel.fromFirestore(String id, Map<String, dynamic> data) {
    return SupportTicketModel(
      id: id,
      subject: data['subject'] as String? ?? 'Support Request',
      category: data['category'] as String? ?? 'General',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'Open',
      priority: data['priority'] as String? ?? 'Normal',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'subject': subject,
        'category': category,
        'message': message,
        'status': status,
        'priority': priority,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

/// Real Backend Service managing Enterprise Help, FAQs, Account Manager & Support Tickets in Firestore.
class EnterpriseHelpSupportService {
  EnterpriseHelpSupportService._internal();
  static final EnterpriseHelpSupportService instance = EnterpriseHelpSupportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Streams real enterprise support tickets from `enterprises/{uid}/support_tickets`.
  Stream<List<SupportTicketModel>> streamSupportTickets([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const []);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('support_tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => SupportTicketModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Submits a new support ticket to Firestore `enterprises/{uid}/support_tickets`.
  Future<bool> submitSupportTicket({
    required String subject,
    required String category,
    required String message,
    String priority = 'Normal',
    String? uid,
  }) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final docRef = _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('support_tickets')
          .doc();

      final ticket = SupportTicketModel(
        id: docRef.id,
        subject: subject.trim(),
        category: category,
        message: message.trim(),
        status: 'Open',
        priority: priority,
        createdAt: DateTime.now(),
      );

      await docRef.set(ticket.toFirestore());
      return true;
    } catch (e) {
      debugPrint('[EnterpriseHelpSupportService] submitSupportTicket error: $e');
      return false;
    }
  }

  /// Sends a direct message request to the Dedicated Account Manager.
  Future<bool> contactAccountManager({
    required String message,
    String? uid,
  }) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final profile = EnterpriseProfileStore.instance.currentProfile;
      final companyName = profile?.companyName ?? 'My Enterprise';

      await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('support_tickets')
          .add({
        'subject': 'Dedicated Account Manager Request from $companyName',
        'category': 'Account Manager VIP',
        'message': message.trim(),
        'status': 'Open',
        'priority': 'High',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('[EnterpriseHelpSupportService] contactAccountManager error: $e');
      return false;
    }
  }

  /// Curated Enterprise FAQ items.
  static List<Map<String, String>> getFaqs() {
    return const [
      {
        "question": "How do I map a custom domain for employee digital cards?",
        "answer":
            "Go to Workspace Settings -> Custom Domain. Enter your subdomain (e.g. cards.yourcompany.com) and add the CNAME record to your DNS registrar (Cloudflare, GoDaddy, etc.).",
      },
      {
        "question": "How can I increase our employee seat limit?",
        "answer":
            "Navigate to Workspace Settings -> Employee Seats. Click on '+ Increase Seats' to adjust your team size in real-time.",
      },
      {
        "question": "Where can I view past invoices and tax receipts?",
        "answer":
            "All official billing statements and receipts are listed under Workspace Settings -> Billing History with downloadable receipt details.",
      },
      {
        "question": "Can I restrict employee card editing and lock brand logos?",
        "answer":
            "Yes, enterprise admins can lock brand banners, colors, and logos across all employee digital cards from the Employee Management page.",
      },
    ];
  }
}
