import 'package:flutter/foundation.dart';
import '../../individual/api_service.dart';

/// Ensures an enterprise's card exists in MongoDB with `cardStatus: "Published"`
/// so that scanning the QR code at mycardshare.com/card/slug loads the
/// live public card page instead of returning a 404.
class EnterpriseSlugBackendService {
  EnterpriseSlugBackendService._();
  static final EnterpriseSlugBackendService instance = EnterpriseSlugBackendService._();

  Future<void> ensureSlugSynced(
    String slug,
    Map<String, dynamic> cardData,
  ) async {
    final cleanSlug = slug.trim().toLowerCase();
    if (cleanSlug.isEmpty) {
      debugPrint('[EnterpriseSlugBackendService] Skipped: slug is empty');
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
            '[EnterpriseSlugBackendService] ✅ Slug "$cleanSlug" synced to MongoDB (Published)');
      } else {
        debugPrint('[EnterpriseSlugBackendService] ⚠️ Unexpected response: $response');
      }
    } catch (e) {
      debugPrint('[EnterpriseSlugBackendService] ⚠️ Sync notice (offline?): $e');
    }
  }
}


