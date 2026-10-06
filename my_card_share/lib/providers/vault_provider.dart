import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaultNotifier extends StateNotifier<List<Map<String, String>>> {
  VaultNotifier() : super([]) {
    fetchFirestoreContacts();
  }

  Future<void> fetchFirestoreContacts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'name': (data['name'] as String?) ?? 'Contact',
            'role': (data['role'] as String?) ?? 'Role',
            'company': (data['company'] as String?) ?? 'Company',
            'phone': (data['phone'] as String?) ?? '',
            'email': (data['email'] as String?) ?? '',
            'website': (data['website'] as String?) ?? '',
            'address': (data['address'] as String?) ?? '',
            'dateAdded': 'Just now',
            'tag': (data['tag'] as String?) ?? 'OCR',
          };
        }).toList();
        state = loaded;
      }
    } catch (e) {
      // Non-fatal
    }
  }

  void addContact(Map<String, String> contact) {
    state = [contact, ...state];
  }
}

final vaultNotifierProvider =
    StateNotifierProvider<VaultNotifier, List<Map<String, String>>>(
  (ref) => VaultNotifier(),
);
