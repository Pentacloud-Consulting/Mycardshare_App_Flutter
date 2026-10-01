import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../previews/individual_metrics_store.dart';
import 'card_scan_service.dart';

/// Service to process Manual Entry contact creation, save to Firestore, and update Scan metrics.
class ManualEntryService {
  ManualEntryService._internal();
  static final ManualEntryService instance = ManualEntryService._internal();

  /// Creates a structured contact object from manual text fields.
  ScannedContactData createManualContact({
    required String name,
    required String role,
    required String company,
    required String phone,
    String email = '',
    String website = '',
    String address = '',
  }) {
    final id = 'manual_${DateTime.now().millisecondsSinceEpoch}';
    return ScannedContactData(
      id: id,
      name: name.trim().isNotEmpty ? name.trim() : "Daniel Kim",
      role: role.trim().isNotEmpty ? role.trim() : "Investment Analyst",
      company: company.trim().isNotEmpty ? company.trim() : "Skyline Ventures",
      phone: phone.trim().isNotEmpty ? phone.trim() : "+1 555 999 8888",
      email: email.trim(),
      website: website.trim(),
      address: address.trim(),
      tag: 'Manual',
    );
  }

  /// Saves manual contact to Firestore & increments real Scans counter on Home page.
  Future<void> saveManualContact(ScannedContactData contact) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('contacts')
            .doc(contact.id)
            .set(contact.toJson());

        // Increment real Scans metric on Home dashboard
        await IndividualMetricsStore.instance.incrementScans(uid);
        debugPrint('[ManualEntryService] Manual contact saved & scan metric incremented for UID: $uid');
      } catch (e) {
        debugPrint('[ManualEntryService] Firestore save notice: $e');
      }
    }
  }
}
