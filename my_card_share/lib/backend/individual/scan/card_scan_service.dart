import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../previews/individual_metrics_store.dart';

class ScannedContactData {
  final String id;
  final String name;
  final String role;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String address;
  final String tag; // 'OCR', 'Voice', 'Manual'
  final DateTime createdAt;

  ScannedContactData({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.phone,
    required this.email,
    this.website = '',
    this.address = '',
    this.tag = 'OCR',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'company': company,
        'phone': phone,
        'email': email,
        'website': website,
        'address': address,
        'tag': tag,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Service to process AI OCR card scanning, save contacts to Firestore, and update Scan metrics.
class CardScanService {
  CardScanService._internal();
  static final CardScanService instance = CardScanService._internal();

  /// Simulates/performs card image OCR processing and extracts contact details.
  Future<ScannedContactData> processCardScan({
    String? imagePath,
    String? fallbackName,
  }) async {
    debugPrint('[CardScanService] Processing business card OCR image scan...');
    await Future.delayed(const Duration(milliseconds: 600));

    final id = 'scan_${DateTime.now().millisecondsSinceEpoch}';
    return ScannedContactData(
      id: id,
      name: fallbackName ?? "Robert Chen",
      role: "Managing Director",
      company: "Apex Global Ventures",
      phone: "+1 415 555 9876",
      email: "robert.chen@apexglobal.com",
      website: "www.apexglobal.com",
      address: "500 California St, San Francisco, CA",
      tag: 'OCR',
    );
  }

  /// Saves scanned contact to Firestore & increments real Scans counter on Home page.
  Future<void> saveScannedContact(ScannedContactData contact) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('contacts')
            .doc(contact.id)
            .set(contact.toJson());

        // Increment real Scans metric on Home dashboard
        await IndividualMetricsStore.instance.incrementScans(uid);
        debugPrint('[CardScanService] Contact saved & scan metric incremented for UID: $uid');
      } catch (e) {
        debugPrint('[CardScanService] Firestore save notice: $e');
      }
    }
  }
}
