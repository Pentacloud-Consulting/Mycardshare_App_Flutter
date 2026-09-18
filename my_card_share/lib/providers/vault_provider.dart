import 'package:flutter_riverpod/flutter_riverpod.dart';

class VaultNotifier extends StateNotifier<List<Map<String, String>>> {
  VaultNotifier()
      : super([
          {
            'name': 'James Miller',
            'role': 'CEO & Founder',
            'company': 'TechNova Solutions',
            'dateAdded': '2 days ago',
            'tag': 'OCR',
          },
          {
            'name': 'Priya Sharma',
            'role': 'Marketing Manager',
            'company': 'GrowthNest Media',
            'dateAdded': '3 days ago',
            'tag': 'Voice',
            'initials': 'PS',
          },
          {
            'name': 'Daniel Kim',
            'role': 'Investment Analyst',
            'company': 'Skyline Ventures',
            'dateAdded': '5 days ago',
            'tag': 'Manual',
          },
          {
            'name': 'Sophia Lee',
            'role': 'Business Development',
            'company': 'Acme Realty Group',
            'dateAdded': '1 week ago',
            'tag': 'OCR',
          },
          {
            'name': 'Rahul Jain',
            'role': 'Product Manager',
            'company': 'FlowSync Technologies',
            'dateAdded': '1 week ago',
            'tag': 'Voice',
            'initials': 'RJ',
          },
        ]);

  void addContact(Map<String, String> contact) {
    state = [contact, ...state];
  }
}

final vaultNotifierProvider =
    StateNotifierProvider<VaultNotifier, List<Map<String, String>>>(
  (ref) => VaultNotifier(),
);
