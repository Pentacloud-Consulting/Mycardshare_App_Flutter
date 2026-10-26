import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../providers/vault_provider.dart';
import '../../../backend/individual/previews/individual_metrics_store.dart';
import '../../../backend/individual/notification/vault_notification_service.dart';
import '../../../backend/individual/vault/contact_duplicate_service.dart';

class VoiceService {
  VoiceService._();

  /// Calculate initials from full name (e.g. "Sarah Jenkins" -> "SJ")
  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'SJ';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Save a voice-dictated contact into the Vault notifier and Firestore
  static Future<void> saveContact(
    WidgetRef ref, {
    required String name,
    String? role,
    String? company,
    String? phone,
    String? email,
  }) async {
    final cleanName = name.trim().isNotEmpty ? name.trim() : 'Contact';
    final cleanRole = (role != null && role.trim().isNotEmpty) ? role.trim() : 'Contact';
    final cleanCompany = (company != null && company.trim().isNotEmpty) ? company.trim() : 'Independent';
    final cleanPhone = phone?.trim() ?? '';
    final cleanEmail = email?.trim() ?? '';
    final initials = getInitials(cleanName);
    final contactId = 'voice_${DateTime.now().millisecondsSinceEpoch}';

    final existingLocal = ref.read(vaultNotifierProvider.notifier).findExistingContact(
      name: cleanName,
      phone: cleanPhone,
      email: cleanEmail,
      company: cleanCompany,
    );
    final targetId = existingLocal?['id'] ?? contactId;

    final contact = {
      'id': targetId,
      'name': cleanName,
      'role': cleanRole,
      'company': cleanCompany,
      'phone': cleanPhone,
      'email': cleanEmail,
      'dateAdded': 'Just now',
      'tag': 'Voice',
      'initials': initials,
    };

    // 1. Instant local state update (deduplicated)
    ref.read(vaultNotifierProvider.notifier).addContact(contact);

    // 2. Direct Firestore persistence
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final existingDoc = await ContactDuplicateService.findDuplicateInFirestore(
          uid: uid,
          name: cleanName,
          phone: cleanPhone,
          email: cleanEmail,
          company: cleanCompany,
          excludeId: targetId,
        );

        final docId = existingDoc?.id ?? targetId;
        final isUpdate = existingDoc != null || existingLocal != null;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('contacts')
            .doc(docId)
            .set({
          'id': docId,
          'name': cleanName,
          'role': cleanRole,
          'company': cleanCompany,
          'phone': cleanPhone,
          'email': cleanEmail,
          'website': '',
          'address': '',
          'tag': 'Voice',
          'initials': initials,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!isUpdate) {
          // 3. Increment scans / voice metrics on dashboard only for new contacts
          await IndividualMetricsStore.instance.incrementScans(uid);

          // 4. Send notification
          await VaultNotificationService.instance.notifyContactSaved(
            targetUid: uid,
            contactName: cleanName,
            method: 'Voice',
          );
        }

        debugPrint('[VoiceService] Voice contact ${isUpdate ? "updated" : "persisted"} to Firestore for UID: $uid (Doc ID: $docId)');
      } catch (e) {
        debugPrint('[VoiceService] Firestore save error: $e');
      }
    }
  }
}


