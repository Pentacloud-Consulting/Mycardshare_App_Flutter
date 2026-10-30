import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS Universal Links & Custom URL Scheme handler for My Card Share.
///
/// Handles:
///   mycardshare://card/<slug>           — View a card
///   mycardshare://invite/<code>         — Enterprise invite
///   mycardshare://connect/<uid>         — Connect request
///   https://mycardshare.com/card/<slug> — Universal Link (same routing)
///
/// Usage:
///   final deepLink = await IOSDeepLinkService.instance.getInitialLink();
///   IOSDeepLinkService.instance.onLinkStream.listen((uri) { ... });
///
/// Wire-up in main.dart (iOS only):
///   if (!kIsWeb && Platform.isIOS) {
///     IOSDeepLinkService.instance.init();
///   }
class IOSDeepLinkService {
  IOSDeepLinkService._internal();
  static final IOSDeepLinkService instance = IOSDeepLinkService._internal();

  static const MethodChannel _channel = MethodChannel('mycardshare/deep_links');
  static const EventChannel _eventChannel = EventChannel('mycardshare/deep_links/stream');

  final StreamController<Uri> _linkController = StreamController<Uri>.broadcast();

  /// Stream of incoming deep-link URIs while the app is running.
  Stream<Uri> get onLinkStream => _linkController.stream;

  /// Initialise listener — call once from main() on iOS.
  void init() {
    if (kIsWeb) return;
    _eventChannel.receiveBroadcastStream().listen(
      (dynamic link) {
        if (link is String && link.isNotEmpty) {
          final uri = Uri.tryParse(link);
          if (uri != null) _linkController.add(uri);
        }
      },
      onError: (dynamic error) {
        debugPrint('[IOSDeepLinkService] Stream error: $error');
      },
    );
  }

  /// Returns the URI that launched the app cold (if any).
  Future<Uri?> getInitialLink() async {
    if (kIsWeb) return null;
    try {
      final String? link = await _channel.invokeMethod<String>('getInitialLink');
      if (link != null && link.isNotEmpty) return Uri.tryParse(link);
    } on PlatformException catch (e) {
      debugPrint('[IOSDeepLinkService] getInitialLink error: $e');
    }
    return null;
  }

  // ─── Route Parsing ────────────────────────────────────────────────────────

  /// Returns the card slug if this URI points to a card, null otherwise.
  static String? cardSlugFromUri(Uri uri) {
    // mycardshare://card/<slug>  OR  https://mycardshare.com/card/<slug>
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'card') {
      return segments[1];
    }
    return null;
  }

  /// Returns the invite code if this URI contains an enterprise invite.
  static String? inviteCodeFromUri(Uri uri) {
    // mycardshare://invite/<code>
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'invite') {
      return segments[1];
    }
    return null;
  }

  /// Returns the UID if this URI contains a connect request.
  static String? connectUidFromUri(Uri uri) {
    // mycardshare://connect/<uid>
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'connect') {
      return segments[1];
    }
    return null;
  }

  void dispose() {
    _linkController.close();
  }
}
