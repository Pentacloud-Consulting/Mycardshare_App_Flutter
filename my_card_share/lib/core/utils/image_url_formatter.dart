import 'package:flutter/foundation.dart';

/// Utility to normalize image URLs across web and mobile platforms.
/// Handles relative upload paths (/api/images/..., /uploads/..., /api/uploads/...),
/// local dev URLs, and data URIs.
class ImageUrlFormatter {
  static String get defaultOrigin {
    if (kIsWeb && kDebugMode) {
      return 'http://localhost:3000';
    }
    return 'https://www.mycardshare.com';
  }

  /// Formats an image URL/URI into a loadable network URL or data URI.
  static String? format(String? rawUrl) {
    if (rawUrl == null) return null;
    final clean = rawUrl.trim();
    if (clean.isEmpty) return null;

    // 1. Data URI (Base64)
    if (clean.startsWith('data:image')) {
      return clean;
    }

    // 2. In local web debug, rewrite production or dead origins to localhost:3000
    if (kIsWeb && kDebugMode) {
      if (clean.contains('mycardshare.com') || clean.contains('mycardshare.in')) {
        final path = clean.replaceFirst(RegExp(r'https?://[^/]+'), '');
        return '$defaultOrigin$path';
      }
    }

    // 3. Relative path starting with '/' (e.g. /api/images/..., /uploads/..., /api/uploads/...)
    if (clean.startsWith('/')) {
      return '$defaultOrigin$clean';
    }

    // 4. Relative path without leading slash (e.g. uploads/..., api/images/...)
    if (clean.startsWith('uploads/') || clean.startsWith('api/')) {
      return '$defaultOrigin/$clean';
    }

    // 5. Dev localhost rewrite to live or local origin
    if (clean.startsWith('http://localhost') ||
        clean.startsWith('https://localhost') ||
        clean.startsWith('http://127.0.0.1') ||
        clean.startsWith('https://127.0.0.1') ||
        clean.startsWith('http://10.0.2.2') ||
        clean.startsWith('https://10.0.2.2')) {
      if (kIsWeb && kDebugMode) {
        final path = clean.replaceFirst(RegExp(r'https?://[^/]+'), '');
        return '$defaultOrigin$path';
      }
      return clean;
    }

    // 6. Absolute HTTP/HTTPS URLs
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }

    // 7. Asset or local file path
    return clean;
  }
}
