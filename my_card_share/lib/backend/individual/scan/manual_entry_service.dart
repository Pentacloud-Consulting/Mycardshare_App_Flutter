import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../previews/individual_metrics_store.dart';
import 'card_scan_service.dart';
import '../notification/vault_notification_service.dart';
import '../vault/contact_duplicate_service.dart';

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
  /// Detects existing duplicate contacts to avoid duplicate Firestore documents.
  Future<void> saveManualContact(ScannedContactData contact) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final contactsRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('contacts');

        // Check if duplicate contact already exists in Firestore
        final existingDoc = await ContactDuplicateService.findDuplicateInFirestore(
          uid: uid,
          name: contact.name,
          phone: contact.phone,
          email: contact.email,
          company: contact.company,
          excludeId: contact.id,
        );

        final targetDocId = existingDoc?.id ?? contact.id;
        final isUpdate = existingDoc != null;

        await contactsRef.doc(targetDocId).set(
              contact.toJson(),
              SetOptions(merge: true),
            );

        if (!isUpdate) {
          // Increment real Scans metric on Home dashboard only for new contacts
          await IndividualMetricsStore.instance.incrementScans(uid);

          // Send real notification to Contact Vault owner
          await VaultNotificationService.instance.notifyContactSaved(
            targetUid: uid,
            contactName: contact.name,
            method: 'Manual',
          );
        }

        debugPrint('[ManualEntryService] Contact ${isUpdate ? "updated" : "saved"} for UID: $uid (Doc ID: $targetDocId)');
      } catch (e) {
        debugPrint('[ManualEntryService] Firestore save notice: $e');
      }
    }
  }
}


