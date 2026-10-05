import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to handle real native Email client / Gmail redirect actions for Individual digital cards.
class EmailConnectService {
  EmailConnectService._internal();
  static final EmailConnectService instance = EmailConnectService._internal();

  /// Launches default email app (Gmail / native mail) pre-filled with [emailAddress].
  Future<bool> sendEmail({
    required String emailAddress,
    String? subject,
    String? body,
  }) async {
    final cleanEmail = emailAddress.trim();
    if (cleanEmail.isEmpty) {
      debugPrint('[EmailConnectService] Warning: Email address is empty.');
      return false;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: cleanEmail,
      queryParameters: {
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        debugPrint('[EmailConnectService] Launched email app for $cleanEmail (success: $launched)');
        return launched;
      } else {
        // Fallback: direct launchUrl attempt
        final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        debugPrint('[EmailConnectService] Fallback launched email app for $cleanEmail (success: $launched)');
        return launched;
      }
    } catch (e) {
      debugPrint('[EmailConnectService] Error launching email app for $cleanEmail: $e');
      return false;
    }
  }
}
