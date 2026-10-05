import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to handle real native Phone Call actions for Individual digital cards.
class PhoneConnectService {
  PhoneConnectService._internal();
  static final PhoneConnectService instance = PhoneConnectService._internal();

  /// Launches the native phone dialer/call app pre-filled with [phoneNumber].
  Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '').trim();
    if (cleanNumber.isEmpty) {
      debugPrint('[PhoneConnectService] Warning: Phone number is empty.');
      return false;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        debugPrint('[PhoneConnectService] Launched phone call for $cleanNumber (success: $launched)');
        return launched;
      } else {
        // Fallback: direct launchUrl attempt
        final launched = await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
        debugPrint('[PhoneConnectService] Fallback launched phone call for $cleanNumber (success: $launched)');
        return launched;
      }
    } catch (e) {
      debugPrint('[PhoneConnectService] Error launching phone call for $phoneNumber: $e');
      return false;
    }
  }
}
