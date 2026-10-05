import 'package:flutter/material.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
import 'sellect_wallet.dart';
import 'google_wallet.dart';
import 'samsung_wallet.dart';
import 'apple_wallet.dart';

/// Coordinator service for mobile wallet operations (Google Wallet, Samsung Wallet, Apple Wallet).
class AddToWalletService {
  AddToWalletService._internal();
  static final AddToWalletService instance = AddToWalletService._internal();

  /// Opens the wallet selection popup dialog/sheet
  Future<void> showSelectWalletModal(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    return SelectWalletModal.show(
      context,
      profile: profile,
      publicProfile: publicProfile,
    );
  }

  /// Add card directly to Google Wallet
  Future<bool> addToGoogleWallet(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    return GoogleWalletService.instance.saveToGoogleWallet(
      context,
      profile: profile,
      publicProfile: publicProfile,
    );
  }

  /// Add card directly to Samsung Wallet
  Future<bool> addToSamsungWallet(
    BuildContext context, {
    IndividualProfileData? profile,
    PublicProfileData? publicProfile,
  }) async {
    return SamsungWalletService.instance.saveToSamsungWallet(
      context,
      profile: profile,
      publicProfile: publicProfile,
    );
  }

  /// Show Apple Wallet Coming Soon notification dialog
  Future<void> showAppleWalletNotice(BuildContext context) async {
    return AppleWalletService.instance.showAppleWalletComingSoon(context);
  }
}
