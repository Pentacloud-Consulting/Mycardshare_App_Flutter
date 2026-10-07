import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';

/// Data representation of Contact details to be exported into native mobile dialer/contacts app.
class ContactExportData {
  final String fullName;
  final String jobTitle;
  final String companyName;
  final String phoneNumber;
  final String emailAddress;
  final String websiteUrl;
  final String shortBio;
  final List<SocialLinkItem> socialLinks;

  const ContactExportData({
    required this.fullName,
    this.jobTitle = '',
    this.companyName = '',
    this.phoneNumber = '',
    this.emailAddress = '',
    this.websiteUrl = '',
    this.shortBio = '',
    this.socialLinks = const [],
  });

  /// Construct ContactExportData from IndividualProfileData or fallback defaults
  factory ContactExportData.fromProfile(
    IndividualProfileData? profile, {
    String? defaultName,
    String? defaultEmail,
    String? defaultPhone,
  }) {
    return ContactExportData(
      fullName: (profile?.fullName.trim().isNotEmpty == true)
          ? profile!.fullName.trim()
          : (defaultName ?? 'User'),
      jobTitle: profile?.jobTitle ?? '',
      companyName: profile?.companyName ?? '',
      phoneNumber: (profile?.phoneNumber.trim().isNotEmpty == true)
          ? profile!.phoneNumber.trim()
          : (defaultPhone ?? ''),
      emailAddress: (profile?.email.trim().isNotEmpty == true)
          ? profile!.email.trim()
          : (defaultEmail ?? ''),
      websiteUrl: profile?.websiteUrl ?? '',
      shortBio: profile?.shortBio ?? '',
      socialLinks: profile?.socialLinks ?? const [],
    );
  }

  /// Construct ContactExportData from PublicProfileData (scanned card view)
  factory ContactExportData.fromPublicProfile(PublicProfileData profile) {
    return ContactExportData(
      fullName: profile.fullName.trim().isNotEmpty ? profile.fullName.trim() : 'Card Contact',
      jobTitle: profile.jobTitle,
      companyName: profile.company,
      phoneNumber: profile.phone.trim(),
      emailAddress: profile.email.trim(),
      websiteUrl: profile.website.trim(),
      shortBio: profile.bio.trim(),
      socialLinks: profile.socialLinks,
    );
  }

  /// Generates a standard vCard 3.0 specification string for full end-to-end mobile dialer import
  String toVCardString() {
    final cleanName = fullName.trim().isEmpty ? 'Card Contact' : fullName.trim();
    final nameParts = cleanName.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCARD');
    buffer.writeln('VERSION:3.0');
    buffer.writeln('FN:$cleanName');
    buffer.writeln('N:$lastName;$firstName;;;');

    if (companyName.trim().isNotEmpty) {
      buffer.writeln('ORG:${companyName.trim()}');
    }
    if (jobTitle.trim().isNotEmpty) {
      buffer.writeln('TITLE:${jobTitle.trim()}');
    }
    if (phoneNumber.trim().isNotEmpty) {
      buffer.writeln('TEL;TYPE=CELL,VOICE:${phoneNumber.trim()}');
    }
    if (emailAddress.trim().isNotEmpty) {
      buffer.writeln('EMAIL;TYPE=INTERNET,WORK:${emailAddress.trim()}');
    }
    if (websiteUrl.trim().isNotEmpty) {
      buffer.writeln('URL:${websiteUrl.trim()}');
    }

    // Combine Short Bio and Social Links into vCard NOTE field
    final notes = <String>[];
    if (shortBio.trim().isNotEmpty) {
      notes.add('Bio: ${shortBio.trim()}');
    }
    if (socialLinks.isNotEmpty) {
      notes.add('Social Links:');
      for (final link in socialLinks) {
        if (link.url.trim().isNotEmpty) {
          notes.add('${link.platform}: ${link.url.trim()}');
        }
      }
    }
    if (notes.isNotEmpty) {
      final joinedNotes = notes.join('\\n');
      buffer.writeln('NOTE:$joinedNotes');
    }

    buffer.writeln('END:VCARD');
    return buffer.toString();
  }
}

/// Service to export & save digital card contacts directly to Android & iOS Mobile Dialer / Contacts app.
class SaveContactService {
  SaveContactService._internal();
  static final SaveContactService instance = SaveContactService._internal();

  /// Export complete user profile to native phone dialer/contacts app via vCard
  Future<bool> saveContactToPhone(ContactExportData data) async {
    if (data.fullName.isEmpty && data.phoneNumber.isEmpty && data.emailAddress.isEmpty) {
      debugPrint('[SaveContactService] Warning: Contact data is empty.');
      return false;
    }

    final vCard = data.toVCardString();
    debugPrint('[SaveContactService] Generated vCard for ${data.fullName}:\n$vCard');

    try {
      // 1. Create vCard data URI
      final encodedVCard = Uri.encodeComponent(vCard);
      final dataUri = Uri.parse('data:text/vcard;charset=utf-8,$encodedVCard');

      if (await canLaunchUrl(dataUri)) {
        final launched = await launchUrl(dataUri, mode: LaunchMode.externalApplication);
        debugPrint('[SaveContactService] Launched vCard data URI for ${data.fullName} (success: $launched)');
        return launched;
      }

      // 2. Fallback: Launch phone dialer with phone number pre-filled
      if (data.phoneNumber.trim().isNotEmpty) {
        final cleanPhone = data.phoneNumber.replaceAll(RegExp(r'[^\d+]'), '').trim();
        final telUri = Uri(scheme: 'tel', path: cleanPhone);
        final launched = await launchUrl(telUri, mode: LaunchMode.externalApplication);
        debugPrint('[SaveContactService] Fallback launched phone dialer for $cleanPhone (success: $launched)');
        return launched;
      }

      return false;
    } catch (e) {
      debugPrint('[SaveContactService] Error saving contact: $e');
      return false;
    }
  }
}


