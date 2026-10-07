import 'package:flutter/foundation.dart';
import '../../individual/api_service.dart';
import '../profile/enterprise_profile_store.dart';

/// Result of an enterprise slug availability check.
class EnterpriseSlugCheckResult {
  final bool isAvailable;
  final ExistingCardInfo? existingCard;

  const EnterpriseSlugCheckResult({
    required this.isAvailable,
    this.existingCard,
  });
}

/// Basic info about the card that already owns a taken slug.
class ExistingCardInfo {
  final String fullName;
  final String jobTitle;
  final String companyName;
  final String avatarUrl;
  final String cardSlug;

  const ExistingCardInfo({
    required this.fullName,
    required this.jobTitle,
    required this.companyName,
    required this.avatarUrl,
    required this.cardSlug,
  });
}

class EnterpriseSlugValidatorService {
  EnterpriseSlugValidatorService._();

  /// Checks if [slug] is available.
  ///
  /// - Hits [GET /api/cards/public/<slug>] (no auth required — public endpoint).
  /// - If a card is found → slug is taken; returns [isAvailable: false] +
  ///   [existingCard] populated with the owner's info.
  /// - If 404 / no card found → slug is available; returns [isAvailable: true].
  ///
  /// [currentUserSlug] — Optional. If provided and matches the found card's
  /// slug, returns [isAvailable: true] (the user is re-saving their own slug).
  static Future<EnterpriseSlugCheckResult> checkSlug(
    String slug, {
    String? currentUserSlug,
  }) async {
    final cleanSlug = slug.trim().toLowerCase();
    if (cleanSlug.isEmpty) {
      return const EnterpriseSlugCheckResult(isAvailable: true);
    }

    if (currentUserSlug != null &&
        currentUserSlug.trim().toLowerCase() == cleanSlug) {
      return const EnterpriseSlugCheckResult(isAvailable: true);
    }

    final activeSlug =
        EnterpriseProfileStore.instance.currentProfile?.cardSlug;
    if (activeSlug != null && activeSlug.toLowerCase() == cleanSlug) {
      return const EnterpriseSlugCheckResult(isAvailable: true);
    }

    try {
      final response =
          await IndividualApiService.getPublic('/api/cards/public/$cleanSlug');

      if (response['success'] == true && response['data'] != null) {
        final cardMap = (response['data'] is Map<String, dynamic>)
            ? (response['data']['card'] ?? response['data'])
                as Map<String, dynamic>?
            : null;

        final existing = cardMap != null
            ? ExistingCardInfo(
                fullName: cardMap['fullName'] as String? ?? 'Another user',
                jobTitle: cardMap['jobTitle'] as String? ?? '',
                companyName: cardMap['companyName'] as String? ?? '',
                avatarUrl: cardMap['avatarUrl'] as String? ?? '',
                cardSlug: cardMap['cardSlug'] as String? ?? cleanSlug,
              )
            : ExistingCardInfo(
                fullName: 'Another user',
                jobTitle: '',
                companyName: '',
                avatarUrl: '',
                cardSlug: cleanSlug,
              );

        return EnterpriseSlugCheckResult(
          isAvailable: false,
          existingCard: existing,
        );
      }
    } catch (e) {
      debugPrint('[EnterpriseSlugValidatorService] API check error: $e');
    }

    return const EnterpriseSlugCheckResult(isAvailable: true);
  }
}


