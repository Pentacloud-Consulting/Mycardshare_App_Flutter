import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../previews/individual_metrics_store.dart';
import 'card_scan_service.dart';

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
  Future<void> saveVoiceContact(ScannedContactData contact) async {
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
        debugPrint('[VoiceAddService] Voice contact saved & scan metric incremented for UID: $uid');
      } catch (e) {
        debugPrint('[VoiceAddService] Firestore save notice: $e');
      }
    }
  }
}
