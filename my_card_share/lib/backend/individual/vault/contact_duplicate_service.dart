import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service dedicated to detecting, finding, and preventing duplicate contacts in the Contact Vault.
class ContactDuplicateService {
  ContactDuplicateService._();
  static final ContactDuplicateService instance = ContactDuplicateService._();

  /// Normalizes phone number to digits only (e.g. "+91 97290 41234" -> "919729041234")
  static String normalizePhone(String? phone) {
    if (phone == null) return '';
    return phone.replaceAll(RegExp(r'[^\d]'), '').trim();
  }

  /// Normalizes email address to lowercase and trimmed
  static String normalizeEmail(String? email) {
    if (email == null) return '';
    return email.trim().toLowerCase();
  }

  /// Normalizes name by lowercasing and stripping all whitespace, hyphens, and underscores
  /// e.g. "test 9" -> "test9", "test9" -> "test9", "John-Doe" -> "johndoe"
  static String normalizeName(String? name) {
    if (name == null) return '';
    return name.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  /// Normalizes company/organization name
  static String normalizeCompany(String? company) {
    if (company == null) return '';
    return company.trim().toLowerCase().replaceAll(RegExp(r'[\s_\-]+'), '');
  }

  /// Determines if two contact records are duplicates of each other
  static bool isDuplicate({
    required Map<String, dynamic> existing,
    required String name,
    String? phone,
    String? email,
    String? company,
    String? excludeId,
  }) {
    final existId = (existing['id'] ?? '').toString().trim();
    if (excludeId != null && excludeId.isNotEmpty && existId.isNotEmpty && existId == excludeId) {
      return false; // Skip comparing against itself
    }

    final existName = (existing['name'] ?? '').toString().trim();
    final existPhone = (existing['phone'] ?? '').toString().trim();
    final existEmail = (existing['email'] ?? '').toString().trim();
    final existCompany = (existing['company'] ?? '').toString().trim();

    // 1. Phone number match (reliable unique identifier, min 7 digits)
    final cleanPhone = normalizePhone(phone);
    final cleanExistPhone = normalizePhone(existPhone);
    if (cleanPhone.length >= 7 && cleanExistPhone.length >= 7) {
      if (cleanPhone == cleanExistPhone ||
          cleanPhone.endsWith(cleanExistPhone) ||
          cleanExistPhone.endsWith(cleanPhone)) {
        return true;
      }
    }

    // 2. Email match (reliable unique identifier)
    final cleanEmail = normalizeEmail(email);
    final cleanExistEmail = normalizeEmail(existEmail);
    if (cleanEmail.isNotEmpty && cleanExistEmail.isNotEmpty && cleanEmail == cleanExistEmail) {
      return true;
    }

    // 3. Name comparison (Normalized matching, e.g. "test9" vs "test 9")
    final normName = normalizeName(name);
    final normExistName = normalizeName(existName);
    if (normName.isNotEmpty && normName == normExistName) {
      final normComp = normalizeCompany(company);
      final normExistComp = normalizeCompany(existCompany);

      // Default/placeholder companies that should not distinguish different people
      const defaultCompanies = {'', 'independent', 'company', 'contact', 'none', 'na', 'n/a'};
      final compIsDefault = defaultCompanies.contains(normComp);
      final existCompIsDefault = defaultCompanies.contains(normExistComp);

      // If companies match OR either company is default/empty, consider duplicate
      if (normComp == normExistComp || compIsDefault || existCompIsDefault) {
        return true;
      }
    }

    return false;
  }

  /// Finds an existing duplicate contact from an in-memory list
  static Map<String, String>? findDuplicateInList(
    List<Map<String, String>> contacts, {
    required String name,
    String? phone,
    String? email,
    String? company,
    String? excludeId,
  }) {
    for (final contact in contacts) {
      if (isDuplicate(
        existing: contact,
        name: name,
        phone: phone,
        email: email,
        company: company,
        excludeId: excludeId,
      )) {
        return contact;
      }
    }
    return null;
  }

  /// Cleans and deduplicates a full list of contacts, keeping the most complete record
  static List<Map<String, String>> deduplicateContactsList(List<Map<String, String>> contacts) {
    final unique = <Map<String, String>>[];
    for (final contact in contacts) {
      final existingIndex = unique.indexWhere((u) => isDuplicate(
            existing: u,
            name: contact['name'] ?? '',
            phone: contact['phone'],
            email: contact['email'],
            company: contact['company'],
          ));

      if (existingIndex == -1) {
        unique.add(contact);
      } else {
        // Merge details: retain existing ID but fill in any empty fields from the duplicate
        final existing = Map<String, String>.from(unique[existingIndex]);
        contact.forEach((key, val) {
          if (val.trim().isNotEmpty && (existing[key] == null || existing[key]!.trim().isEmpty)) {
            existing[key] = val;
          }
        });
        unique[existingIndex] = existing;
      }
    }
    return unique;
  }

  /// Queries Firestore `users/{uid}/contacts` to check if a duplicate contact already exists
  static Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findDuplicateInFirestore({
    required String uid,
    required String name,
    String? phone,
    String? email,
    String? company,
    String? excludeId,
  }) async {
    if (uid.isEmpty) return null;

    try {
      final contactsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts');

      // Check 1: By phone if provided
      final cleanPhone = normalizePhone(phone);
      if (cleanPhone.length >= 7) {
        final phoneSnap = await contactsRef.get();
        for (final doc in phoneSnap.docs) {
          if (excludeId != null && doc.id == excludeId) continue;
          final docPhone = normalizePhone(doc.data()['phone']?.toString());
          if (docPhone.length >= 7 && (docPhone == cleanPhone || docPhone.endsWith(cleanPhone) || cleanPhone.endsWith(docPhone))) {
            return doc;
          }
        }
      }

      // Check 2: By email if provided
      final cleanEmail = normalizeEmail(email);
      if (cleanEmail.isNotEmpty) {
        final emailSnap = await contactsRef.where('email', isEqualTo: email!.trim()).get();
        for (final doc in emailSnap.docs) {
          if (excludeId != null && doc.id == excludeId) continue;
          return doc;
        }
      }

      // Check 3: By normalized name and company
      final allDocs = await contactsRef.get();
      for (final doc in allDocs.docs) {
        if (excludeId != null && doc.id == excludeId) continue;
        if (isDuplicate(
          existing: doc.data(),
          name: name,
          phone: phone,
          email: email,
          company: company,
          excludeId: excludeId,
        )) {
          return doc;
        }
      }
    } catch (e) {
      debugPrint('[ContactDuplicateService] Firestore check notice: $e');
    }
    return null;
  }
}
