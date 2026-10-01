import 'package:flutter/foundation.dart';
import '../api_service.dart';
import '../profile/individual_profile_store.dart';

/// Result of a slug availability check.
class SlugCheckResult {
  /// True if the slug is free to use; false if already taken.
  final bool isAvailable;

  /// If [isAvailable] is false, this holds the existing card owner's basic info.
  final ExistingCardInfo? existingCard;

  const SlugCheckResult({
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

/// Validates whether a card slug is available in MongoDB before saving.
///
/// Usage in the onboarding form slug field:
/// ```dart
/// import 'package:my_card_share/backend/individual/qr scan/slug_validator.dart';
///
/// final result = await SlugValidatorService.checkSlug('zuhaib');
/// if (!result.isAvailable) {
///   // Show: "Slug 'zuhaib' is already taken by ${result.existingCard!.fullName}"
/// }
/// ```
class SlugValidatorService {
  SlugValidatorService._();

  /// Checks if [slug] is available.
  ///
  /// - Hits [GET /api/cards/public/<slug>] (no auth required — public endpoint).
  /// - If a card is found → slug is taken; returns [isAvailable: false] +
  ///   [existingCard] populated with the owner's info.
  /// - If 404 / no card found → slug is available; returns [isAvailable: true].
  ///
  /// [currentUserSlug] — Optional. If provided and matches the found card's
  /// slug, returns [isAvailable: true] (the user is re-saving their own slug).
  static Future<SlugCheckResult> checkSlug(
    String slug, {
    String? currentUserSlug,
  }) async {
    final cleanSlug = slug.trim().toLowerCase();
    if (cleanSlug.isEmpty) {
      return const SlugCheckResult(isAvailable: true);
    }

    // The user is re-submitting their own existing slug — always OK.
    if (currentUserSlug != null &&
        currentUserSlug.trim().toLowerCase() == cleanSlug) {
      return const SlugCheckResult(isAvailable: true);
    }

    // Also check against the locally active profile's slug to avoid false
    // "taken" errors during the very first form submission.
    final activeSlug =
        IndividualProfileStore.instance.activeProfile?.cardSlug;
    if (activeSlug != null && activeSlug.toLowerCase() == cleanSlug) {
      return const SlugCheckResult(isAvailable: true);
    }

    try {
      final response =
          await IndividualApiService.getPublic('/api/cards/public/$cleanSlug');

      // A successful response means the slug is already owned by someone.
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

        debugPrint(
            '[SlugValidatorService] ❌ Slug "$cleanSlug" is taken by: ${existing.fullName}');
        return SlugCheckResult(isAvailable: false, existingCard: existing);
      }

      // Unexpected response format — assume available (be lenient).
      debugPrint(
          '[SlugValidatorService] ✅ Slug "$cleanSlug" appears available (unexpected response shape)');
      return const SlugCheckResult(isAvailable: true);
    } catch (e) {
      final errStr = e.toString();

      // HTTP 404 means no card found → slug is free.
      if (errStr.contains('404') ||
          errStr.contains('not found') ||
          errStr.contains('Card not found')) {
        debugPrint('[SlugValidatorService] ✅ Slug "$cleanSlug" is free (404)');
        return const SlugCheckResult(isAvailable: true);
      }

      // Network error / server down — allow the user to proceed optimistically.
      debugPrint(
          '[SlugValidatorService] ⚠️ Could not validate slug (network issue): $e');
      return const SlugCheckResult(isAvailable: true);
    }
  }
}
