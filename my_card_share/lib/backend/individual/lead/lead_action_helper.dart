import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'active_lead.dart';

class LeadActionHelper {
  /// 1. REAL PHONE CALL (Opens native phone dialer)
  static Future<void> callLead(BuildContext context, {required String name, required String? phone}) async {
    final rawPhone = (phone ?? '').trim();
    final cleanDigits = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (rawPhone.isEmpty || rawPhone.toLowerCase() == 'not provided' || cleanDigits.isEmpty) {
      _showFeedback(context, "No phone number provided for $name", isError: true);
      return;
    }

    final uri = Uri.parse("tel:$cleanDigits");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, "Could not open dialer: $e", isError: true);
      }
    }
  }

  /// 2. REAL SMS MESSAGE (Opens native SMS app)
  static Future<void> messageLead(BuildContext context, {required String name, required String? phone}) async {
    final rawPhone = (phone ?? '').trim();
    final cleanDigits = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');

    if (rawPhone.isEmpty || rawPhone.toLowerCase() == 'not provided' || cleanDigits.isEmpty) {
      _showFeedback(context, "No phone number provided to message $name", isError: true);
      return;
    }

    final uri = Uri.parse("sms:$cleanDigits");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, "Could not open SMS messenger: $e", isError: true);
      }
    }
  }

  /// 3. REAL EMAIL COMPOSER (Opens native Mail app)
  static Future<void> emailLead(BuildContext context, {required String name, required String? email}) async {
    final rawEmail = (email ?? '').trim();

    if (rawEmail.isEmpty || rawEmail.toLowerCase() == 'not provided' || !rawEmail.contains('@')) {
      _showFeedback(context, "No email address provided for $name", isError: true);
      return;
    }

    final uri = Uri.parse("mailto:$rawEmail?subject=${Uri.encodeComponent('Connecting via My Card Share')}");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, "Could not open email app: $e", isError: true);
      }
    }
  }

  /// 4. REAL SYSTEM SHARE (Native Share Sheet)
  static Future<void> shareLead(BuildContext context, LeadData lead) async {
    final buffer = StringBuffer();
    buffer.writeln("Lead: ${lead.name}");
    if (lead.company.trim().isNotEmpty) buffer.writeln("Company: ${lead.company.trim()}");
    if (lead.phone.trim().isNotEmpty && lead.phone.trim().toLowerCase() != 'not provided') {
      buffer.writeln("Phone: ${lead.phone.trim()}");
    }
    if (lead.email.trim().isNotEmpty && lead.email.trim().toLowerCase() != 'not provided') {
      buffer.writeln("Email: ${lead.email.trim()}");
    }
    if (lead.website.trim().isNotEmpty && lead.website.trim().toLowerCase() != 'not provided') {
      buffer.writeln("Website: ${lead.website.trim()}");
    }
    if (lead.location.trim().isNotEmpty && lead.location.trim().toLowerCase() != 'not provided') {
      buffer.writeln("Location: ${lead.location.trim()}");
    }
    if (lead.notes.trim().isNotEmpty) {
      buffer.writeln("Notes: ${lead.notes.trim()}");
    }
    buffer.writeln("\nShared via My Card Share");

    try {
      await Share.share(buffer.toString(), subject: "Lead Details: ${lead.name}");
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, "Could not share lead: $e", isError: true);
      }
    }
  }

  /// 5. REAL OPEN WEBSITE OR MAPS
  static Future<void> openUrl(BuildContext context, String url) async {
    String formattedUrl = url.trim();
    if (formattedUrl.isEmpty || formattedUrl.toLowerCase() == 'not provided') return;

    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.tryParse(formattedUrl);
    if (uri == null) {
      _showFeedback(context, "Invalid web address: $url", isError: true);
      return;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showFeedback(context, "Cannot open $formattedUrl", isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, "Could not open browser: $e", isError: true);
      }
    }
  }

  /// 6. REAL CLIPBOARD COPY
  static void copyToClipboard(BuildContext context, String text, String label) {
    if (text.isEmpty || text.toLowerCase() == 'not provided') return;
    Clipboard.setData(ClipboardData(text: text));
    _showFeedback(context, "Copied $label to clipboard", isError: false);
  }

  static void _showFeedback(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
