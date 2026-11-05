import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../backend/individual/vault/contact_duplicate_service.dart';
import '../backend/individual/api_service.dart';

class VaultNotifier extends StateNotifier<List<Map<String, String>>> {
  VaultNotifier() : super([]) {
    fetchFirestoreContacts();
  }

  Future<void> fetchFirestoreContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    final List<Map<String, String>> loaded = [];

    // 0. Fetch MongoDB vault cards from Next.js API (/api/sync/individual)
    try {
      final apiRes = await IndividualApiService.get('/api/sync/individual');
      if (apiRes['success'] == true && apiRes['data']?['vault'] is List) {
        for (final v in apiRes['data']['vault']) {
          if (v is Map<String, dynamic>) {
            loaded.add({
              'id': (v['id'] ?? '').toString(),
              'name': (v['contactName'] ?? 'Contact').toString(),
              'role': (v['jobTitle'] ?? '').toString(),
              'company': (v['company'] ?? '').toString(),
              'phone': (v['phone'] ?? '').toString(),
              'email': (v['email'] ?? '').toString(),
              'website': '',
              'address': '',
              'dateAdded': 'Recently',
              'tag': 'Web Sync',
            });
          }
        }
      }
    } catch (_) {}

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          loaded.add({
            'id': doc.id,
            'name': (data['name'] as String?) ?? 'Contact',
            'role': (data['role'] as String?) ?? 'Role',
            'company': (data['company'] as String?) ?? 'Company',
            'phone': (data['phone'] as String?) ?? '',
            'email': (data['email'] as String?) ?? '',
            'website': (data['website'] as String?) ?? '',
            'address': (data['address'] as String?) ?? '',
            'dateAdded': 'Just now',
            'tag': (data['tag'] as String?) ?? 'OCR',
          });
        }
      }

      state = ContactDuplicateService.deduplicateContactsList(loaded);
    } catch (e) {
      if (loaded.isNotEmpty) {
        state = ContactDuplicateService.deduplicateContactsList(loaded);
      }
    }
  }

  /// Finds an existing contact with matching phone, email, or normalized name + company
  Map<String, String>? findExistingContact({
    required String name,
    String? phone,
    String? email,
    String? company,
    String? excludeId,
  }) {
    return ContactDuplicateService.findDuplicateInList(
      state,
      name: name,
      phone: phone,
      email: email,
      company: company,
      excludeId: excludeId,
    );
  }

  /// Adds or updates contact in vault without creating duplicates
  void addContact(Map<String, String> contact, {bool updateIfExists = true}) {
    final existing = findExistingContact(
      name: contact['name'] ?? '',
      phone: contact['phone'],
      email: contact['email'],
      company: contact['company'],
    );

    if (existing != null) {
      if (updateIfExists) {
        // Update existing contact in place rather than creating duplicate
        final targetId = existing['id'] ?? contact['id'] ?? '';
        state = state.map((c) {
          if (c == existing || (targetId.isNotEmpty && c['id'] == targetId)) {
            return {
              ...c,
              ...contact,
              if (targetId.isNotEmpty) 'id': targetId,
            };
          }
          return c;
        }).toList();
      }
      return;
    }

    state = [contact, ...state];
  }

  Future<void> deleteContact({String? id, required String name, String? email}) async {
    // 1. Remove optimistically from local state
    state = state.where((c) {
      if (id != null && id.isNotEmpty && c['id'] != null && c['id']!.isNotEmpty) {
        return c['id'] != id;
      }
      final nameMatch = c['name']?.trim().toLowerCase() == name.trim().toLowerCase();
      final emailMatch = email != null && email.isNotEmpty && c['email']?.trim().toLowerCase() == email.trim().toLowerCase();
      if (emailMatch) return false;
      return !nameMatch;
    }).toList();

    // 2. Delete from Firestore if authenticated
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final contactsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts');

      if (id != null && id.isNotEmpty) {
        await contactsRef.doc(id).delete();
      } else {
        // Find documents with matching name or email
        final querySnap = await contactsRef.where('name', isEqualTo: name.trim()).get();
        for (final doc in querySnap.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      // Non-fatal
    }
  }
}

final vaultNotifierProvider =
    StateNotifierProvider<VaultNotifier, List<Map<String, String>>>(
  (ref) => VaultNotifier(),
);


