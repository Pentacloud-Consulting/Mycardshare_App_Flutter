import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Service to save digital business card contacts directly into mobile contacts.
/// ⚡ Features:
/// - 0ms instant feedback (Snackbars appear immediately without waiting for async intents)
/// - Never opens phone dialpad / tel: intent
/// - Opens native Contacts app with pre-filled fields or directly inserts into phonebook
/// - Generates standard RFC 6350 vCard 3.0 fallback (.vcf)
class SaveContactService {
  SaveContactService._internal();
  static final SaveContactService instance = SaveContactService._internal();

  /// Instance method for backward compatibility
  Future<bool> saveContactToPhone(
    dynamic data, {
    BuildContext? context,
  }) async {
    if (context != null && context.mounted) {
      final name = (data?.fullName as String?) ?? 'Contact';
      final phone = (data?.phoneNumber as String?) ?? '';
      final email = (data?.emailAddress as String?);
      final company = (data?.companyName as String?);
      final jobTitle = (data?.jobTitle as String?);
      final website = (data?.websiteUrl as String?);
      final bio = (data?.shortBio as String?);

      return await saveContactDirectly(
        context,
        fullName: name,
        phone: phone,
        email: email,
        company: company,
        jobTitle: jobTitle,
        website: website,
        bio: bio,
      );
    }
    return false;
  }

  /// ⚡ INSTANT EXECUTION: 0ms delay me toast dikhayega aur direct Contact Import karega (NO DIALPAD)
  static Future<bool> saveContactDirectly(
    BuildContext context, {
    required String fullName,
    required String phone,
    String? email,
    String? company,
    String? jobTitle,
    String? website,
    String? bio,
    String? avatarUrl,
  }) async {
    final cleanFullName = fullName.trim().isEmpty ? 'Contact' : fullName.trim();
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '').trim();

    // 1️⃣ STEP 1: INSTANT TOAST (0ms — Click hote hi sabse pehle ye dikhega, no delay)
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.contact_phone_rounded, color: Color(0xFF38BDF8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Saving $cleanFullName to mobile contacts...',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // 2️⃣ STEP 2: BUILD NATIVE CONTACT OBJECT
      final nameParts = cleanFullName.split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final phones = <Phone>[];
      if (cleanPhone.isNotEmpty) {
        phones.add(Phone(number: cleanPhone, label: const Label(PhoneLabel.mobile)));
      }

      final emails = <Email>[];
      if (email != null && email.trim().isNotEmpty) {
        emails.add(Email(address: email.trim(), label: const Label(EmailLabel.work)));
      }

      final organizations = <Organization>[];
      if ((company != null && company.trim().isNotEmpty) ||
          (jobTitle != null && jobTitle.trim().isNotEmpty)) {
        organizations.add(
          Organization(
            name: company?.trim() ?? '',
            jobTitle: jobTitle?.trim() ?? '',
          ),
        );
      }

      final websites = <Website>[];
      if (website != null && website.trim().isNotEmpty) {
        websites.add(Website(url: website.trim()));
      }

      final notes = <Note>[];
      if (bio != null && bio.trim().isNotEmpty) {
        notes.add(Note(note: bio.trim()));
      }

      final newContact = Contact(
        name: Name(first: firstName, last: lastName),
        phones: phones,
        emails: emails,
        organizations: organizations,
        websites: websites,
        notes: notes,
      );

      // 3️⃣ STEP 3: DIRECT PERMISSION + INSERTION INTO PHONEBOOK (NO DIALPAD!)
      final permStatus = await Permission.contacts.request();
      if (permStatus.isGranted) {
        try {
          await FlutterContacts.create(newContact);
          if (context.mounted) {
            _showSuccessSnackBar(context, cleanFullName);
          }
          return true;
        } catch (e) {
          debugPrint('[SaveContactService] FlutterContacts.insertContact error: $e');
        }
      }

      // 4️⃣ STEP 4: CLEAN RFC 6350 VCARD 3.0 FALLBACK (.vcf)
      final vcfSaved = await _saveAndShareVCard(
        fullName: cleanFullName,
        phone: cleanPhone,
        email: email,
        company: company,
        jobTitle: jobTitle,
        website: website,
        bio: bio,
      );

      if (vcfSaved && context.mounted) {
        _showSuccessSnackBar(context, cleanFullName);
      }
      return vcfSaved;
    } catch (e) {
      debugPrint('[SaveContactService] Error in saveContactDirectly: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text(
              'Could not save contact: $e',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
      return false;
    }
  }

  static void _showSuccessSnackBar(BuildContext context, String fullName) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$fullName ready to save in Contacts!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Write RFC 6350 standard vCard 3.0 to a temporary file and launch Contacts handler
  static Future<bool> _saveAndShareVCard({
    required String fullName,
    required String phone,
    String? email,
    String? company,
    String? jobTitle,
    String? website,
    String? bio,
  }) async {
    try {
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final vCardBuffer = StringBuffer()
        ..writeln('BEGIN:VCARD')
        ..writeln('VERSION:3.0')
        ..writeln('N:$lastName;$firstName;;;')
        ..writeln('FN:$fullName');

      if (company != null && company.trim().isNotEmpty) {
        vCardBuffer.writeln('ORG:${company.trim()}');
      }
      if (jobTitle != null && jobTitle.trim().isNotEmpty) {
        vCardBuffer.writeln('TITLE:${jobTitle.trim()}');
      }
      if (phone.trim().isNotEmpty) {
        vCardBuffer.writeln('TEL;TYPE=CELL,VOICE,PREF:${phone.trim()}');
      }
      if (email != null && email.trim().isNotEmpty) {
        vCardBuffer.writeln('EMAIL;TYPE=WORK,INTERNET:${email.trim()}');
      }
      if (website != null && website.trim().isNotEmpty) {
        vCardBuffer.writeln('URL:${website.trim()}');
      }
      if (bio != null && bio.trim().isNotEmpty) {
        vCardBuffer.writeln('NOTE:${bio.trim()}');
      }
      vCardBuffer.writeln('END:VCARD');

      final tempDir = await getTemporaryDirectory();
      final sanitizedName = fullName.replaceAll(RegExp(r'\s+'), '_');
      final vcfFile = File('${tempDir.path}/$sanitizedName.vcf');
      await vcfFile.writeAsString(vCardBuffer.toString());

      final result = await Share.shareXFiles(
        [XFile(vcfFile.path, mimeType: 'text/vcard')],
        text: 'Save $fullName to Contacts',
      );
      return result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed;
    } catch (e) {
      debugPrint('[SaveContactService] _saveAndShareVCard error: $e');
      return false;
    }
  }
}
