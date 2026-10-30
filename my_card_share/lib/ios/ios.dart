/// iOS Platform Services — My Card Share
///
/// Single import barrel for all iOS-specific services:
///
///   import 'package:my_card_share/ios/ios.dart';
///
/// Each service is Platform-guarded (Platform.isIOS) and safe to import
/// on all platforms — non-iOS calls return gracefully without side effects.
library ios;

export 'ios_platform_service.dart';
export 'ios_nfc_service.dart';
export 'ios_wallet_service.dart';
export 'ios_sign_in_service.dart';
export 'ios_permissions_service.dart';
export 'ios_deep_link_service.dart';
export 'ios_notification_service.dart';
