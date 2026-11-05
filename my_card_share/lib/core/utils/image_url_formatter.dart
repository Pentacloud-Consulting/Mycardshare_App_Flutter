/// Utility to normalize image URLs across web and mobile platforms.
/// Handles relative upload paths (/api/images/..., /uploads/..., /api/uploads/...),
/// local dev URLs, and data URIs.
class ImageUrlFormatter {
  static const String defaultOrigin = 'https://mycardshare.com';

  /// Formats an image URL/URI into a loadable network URL or data URI.
  static String? format(String? rawUrl) {
    if (rawUrl == null) return null;
    final clean = rawUrl.trim();
    if (clean.isEmpty) return null;

    // 1. Data URI (Base64)
    if (clean.startsWith('data:image')) {
      return clean;
    }

    // 2. Relative path starting with '/' (e.g. /api/images/..., /uploads/..., /api/uploads/...)
    if (clean.startsWith('/')) {
      return '$defaultOrigin$clean';
    }

    // 3. Relative path without leading slash (e.g. uploads/..., api/images/...)
    if (clean.startsWith('uploads/') || clean.startsWith('api/')) {
      return '$defaultOrigin/$clean';
    }

    // 4. Dev localhost rewrite to live origin
    if (clean.startsWith('http://localhost') ||
        clean.startsWith('https://localhost') ||
        clean.startsWith('http://127.0.0.1') ||
        clean.startsWith('https://127.0.0.1') ||
        clean.startsWith('http://10.0.2.2') ||
        clean.startsWith('https://10.0.2.2')) {
      final path = clean.replaceFirst(RegExp(r'https?://[^/]+'), '');
      return '$defaultOrigin$path';
    }

    // 5. Absolute HTTP/HTTPS URLs
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }

    // 6. Asset or local file path
    return clean;
  }
}
