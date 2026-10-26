import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/vault_provider.dart';

class ManualService {
  ManualService._();

  /// Calculate initials from full name (e.g. "Daniel Kim" -> "DK")
  static String getInitials(String name) {
    if (name.trim().isEmpty) return 'MC';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Save a manually created contact into the Vault notifier (deduplicated)
  static void saveContact(
    WidgetRef ref, {
    required String name,
    String? role,
    String? company,
    String? phone,
    String? email,
  }) {
    final cleanName = name.trim();
    final cleanPhone = phone?.trim() ?? '';
    final cleanEmail = email?.trim() ?? '';
    final cleanCompany = (company != null && company.trim().isNotEmpty) ? company.trim() : 'Independent';
    final cleanRole = (role != null && role.trim().isNotEmpty) ? role.trim() : 'Contact';
    final initials = getInitials(cleanName);

    final existing = ref.read(vaultNotifierProvider.notifier).findExistingContact(
          name: cleanName,
          phone: cleanPhone,
          email: cleanEmail,
          company: cleanCompany,
        );

    final contact = {
      if (existing?['id'] != null && existing!['id']!.isNotEmpty)
        'id': existing['id']!
      else
        'id': 'manual_${DateTime.now().millisecondsSinceEpoch}',
      'name': cleanName,
      'role': cleanRole,
      'company': cleanCompany,
      'phone': cleanPhone,
      'email': cleanEmail,
      'dateAdded': 'Just now',
      'tag': 'Manual',
      'initials': initials,
    };

    ref.read(vaultNotifierProvider.notifier).addContact(contact);
  }
}


