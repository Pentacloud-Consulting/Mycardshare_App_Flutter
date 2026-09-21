import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/vault_provider.dart';

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

  /// Save a voice-dictated contact into the Vault notifier
  static void saveContact(
    WidgetRef ref, {
    required String name,
    String? role,
    String? company,
    String? phone,
    String? email,
  }) {
    final initials = getInitials(name);
    final contact = {
      'name': name.trim(),
      'role': (role != null && role.trim().isNotEmpty) ? role.trim() : 'Contact',
      'company': (company != null && company.trim().isNotEmpty) ? company.trim() : 'Independent',
      'phone': phone?.trim() ?? '',
      'email': email?.trim() ?? '',
      'dateAdded': 'Just now',
      'tag': 'Voice',
      'initials': initials,
    };

    ref.read(vaultNotifierProvider.notifier).addContact(contact);
  }
}
