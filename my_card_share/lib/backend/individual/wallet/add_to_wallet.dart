import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
import 'sellect_wallet.dart';
import 'google_wallet.dart';
import 'samsung_wallet.dart';
import 'apple_wallet.dart';

/// Coordinator service for mobile wallet operations.
/// On iOS: only Apple Wallet (Coming Soon) is shown.
/// On Android: Google Wallet, Samsung Wallet, Apple Wallet selection modal.
class AddToWalletService {
  AddToWalletService._internal();
  static final AddToWalletService instance = AddToWalletService._internal();

  /// Returns true if running on iOS (not web)
  bool get _isIOS => !kIsWeb && Platform.isIOS;

  /// Opens the wallet selection popup.
  /// On iOS → shows Apple Wallet Coming Soon directly.
  /// On Android → opens full SelectWalletModal (Google, Samsung, Apple).
  Future<void> showSelectWalletModal(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    if (_isIOS) {
      // iOS: only Apple Wallet supported (coming soon)
      return AppleWalletService.instance.showAppleWalletComingSoon(context);
    }
    return SelectWalletModal.show(
      context,
      profile: profile,
      publicProfile: publicProfile,
    );
  }

  /// Add card directly to Google Wallet (Android only).
  Future<bool> addToGoogleWallet(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    if (_isIOS) return false;
    return GoogleWalletService.instance.saveToGoogleWallet(
      context,
      profile: profile,
      publicProfile: publicProfile,
    );
  }

  /// Add card directly to Samsung Wallet (Android only).
  Future<bool> addToSamsungWallet(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    if (_isIOS) return false;
    return SamsungWalletService.instance.saveToSamsungWallet(
      context,
      profile: profile,
      publicProfile: publicProfile,
    );
  }

  /// Show Apple Wallet Coming Soon notification dialog.
  Future<void> showAppleWalletNotice(BuildContext context) async {
    return AppleWalletService.instance.showAppleWalletComingSoon(context);
  }
}
