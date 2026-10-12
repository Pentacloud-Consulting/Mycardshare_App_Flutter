import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to handle real native Email client / Gmail redirect actions for Individual digital cards.
class EmailConnectService {
  EmailConnectService._internal();
  static final EmailConnectService instance = EmailConnectService._internal();

  /// Helper to safely encode query parameters for mailto scheme per RFC 6068 (using %20 instead of + for spaces).
  static String? encodeQueryParameters(Map<String, String> params) {
    final entries = params.entries
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.trim())}')
        .toList();
    return entries.isEmpty ? null : entries.join('&');
  }

  /// Launches default email app (Gmail / native mail) pre-filled with [emailAddress].
  /// Uses RFC 6068 %20 percent-encoding so that spaces appear cleanly in subject and body without '+' artifacts.
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

    final Map<String, String> params = {};
    if (subject != null && subject.isNotEmpty) params['subject'] = subject;
    if (body != null && body.isNotEmpty) params['body'] = body;

    final query = encodeQueryParameters(params);

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: cleanEmail,
      query: query,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        debugPrint('[EmailConnectService] Launched email app for $cleanEmail (success: $launched)');
        return launched;
      } else {
        // Fallback: direct launchUrl attempt
        final launched = await launchUrl(emailUri);
        debugPrint('[EmailConnectService] Fallback launched email app for $cleanEmail (success: $launched)');
        return launched;
      }
    } catch (e) {
      debugPrint('[EmailConnectService] Error launching email app for $cleanEmail: $e');
      return false;
    }
  }

  /// Copies email address to system clipboard
  Future<void> copyEmailToClipboard(String emailAddress) async {
    final cleanEmail = emailAddress.trim();
    if (cleanEmail.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: cleanEmail));
    }
  }
}


