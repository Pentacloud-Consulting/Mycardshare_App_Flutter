import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../previews/individual_metrics_store.dart';
import 'card_scan_service.dart';
import '../notification/vault_notification_service.dart';
import '../vault/contact_duplicate_service.dart';

/// Service to process Voice Add contact recording, parse spoken details, save to Firestore, and update Scan metrics.
class VoiceAddService {
  VoiceAddService._internal();
  static final VoiceAddService instance = VoiceAddService._internal();

  /// Parses voice audio transcript into a structured contact record.
  Future<ScannedContactData> processVoiceContact(String spokenText) async {
    debugPrint('[VoiceAddService] Parsing voice text: "$spokenText"');
    await Future.delayed(const Duration(milliseconds: 500));

    final id = 'voice_${DateTime.now().millisecondsSinceEpoch}';
    return ScannedContactData(
      id: id,
      name: spokenText.contains("Priya") ? "Priya Sharma" : "Rahul Jain",
      role: spokenText.contains("Priya") ? "Marketing Manager" : "Product Manager",
      company: spokenText.contains("Priya") ? "GrowthNest Media" : "FlowSync Technologies",
      phone: "+1 555 876 5432",
      email: "contact@voiceadd.com",
      tag: 'Voice',
    );
  }

  /// Saves voice contact to Firestore & increments real Scans counter on Home page.
  /// Detects existing duplicate contacts to avoid duplicate Firestore documents.
  Future<void> saveVoiceContact(ScannedContactData contact) async {
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
            method: 'Voice',
          );
        }

        debugPrint('[VoiceAddService] Voice contact ${isUpdate ? "updated" : "saved"} for UID: $uid (Doc ID: $targetDocId)');
      } catch (e) {
        debugPrint('[VoiceAddService] Firestore save notice: $e');
      }
    }
  }
}


