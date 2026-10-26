import '../profile/individual_profile_store.dart';
import '../scan_profile_view/scan_profile_view.dart';
export '../../contact/save_contact_service.dart';

/// Data representation of Contact details to be exported into native mobile contacts app.
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

  /// Generates a standard vCard 3.0 specification string for full contact import
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



