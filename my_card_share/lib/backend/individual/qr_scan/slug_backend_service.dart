import 'package:flutter/foundation.dart';
import '../api_service.dart';

/// Ensures a user's card exists in MongoDB with `cardStatus: "Published"`
/// so that scanning the QR code at mycardshare.com/card/slug loads the
/// live public card page instead of returning a 404.
///
/// Call this after [IndividualProfileStore.saveProfile()] in the onboarding
/// form or profile editor — it is a fire-and-forget background sync.
class SlugBackendService {
  SlugBackendService._();
  static final SlugBackendService instance = SlugBackendService._();

  /// Pushes the card to MongoDB via [PATCH /api/cards] with all required
  /// fields, including [cardStatus: "Published"] so the public web route
  /// renders the card.
  ///
  /// [slug] — The chosen card slug (used as the URL path segment).
  /// [cardData] — A map of card fields to upsert. These are merged with
  ///              any existing document in MongoDB (createOrUpdate).
  Future<void> ensureSlugSynced(
    String slug,
    Map<String, dynamic> cardData,
  ) async {
    final cleanSlug = slug.trim().toLowerCase();
    if (cleanSlug.isEmpty) {
      debugPrint('[SlugBackendService] Skipped: slug is empty');
      return;
    }

    // Always enforce Published status so the web card page renders.
    final payload = {
      ...cardData,
      'cardSlug': cleanSlug,
      'cardStatus': 'Published',
    };

    try {
      final response = await IndividualApiService.patch('/api/cards', payload);
      final ok = response['success'] == true ||
          (response['message'] != null &&
              (response['message'] as String).contains('Card'));
      if (ok) {
        debugPrint(
            '[SlugBackendService] ✅ Slug "$cleanSlug" synced to MongoDB (Published)');
      } else {
        debugPrint('[SlugBackendService] ⚠️ Unexpected response: $response');
      }
    } catch (e) {
      // Non-fatal — Firestore remains the source of truth for the mobile app.
      debugPrint('[SlugBackendService] ⚠️ Sync notice (offline?): $e');
    }
  }
}


