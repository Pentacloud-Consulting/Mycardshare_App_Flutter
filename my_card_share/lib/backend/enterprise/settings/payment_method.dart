import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Real Data Model for Enterprise Payment Method stored in Firestore.
class PaymentMethodData {
  final String id;
  final String brand; // Visa, Mastercard, Amex, Discover
  final String last4;
  final String expMonth;
  final String expYear;
  final String holderName;
  final bool isPrimary;
  final DateTime? createdAt;

  const PaymentMethodData({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    required this.holderName,
    this.isPrimary = true,
    this.createdAt,
  });

  String get formattedLast4 => last4.isNotEmpty ? '•••• $last4' : 'Not set';
  String get formattedExpiry => (expMonth.isNotEmpty && expYear.isNotEmpty) ? '$expMonth/$expYear' : '';

  factory PaymentMethodData.fromFirestore(String docId, Map<String, dynamic> data) {
    return PaymentMethodData(
      id: docId,
      brand: data['brand'] as String? ?? 'Visa',
      last4: data['last4'] as String? ?? '',
      expMonth: data['expMonth'] as String? ?? '',
      expYear: data['expYear'] as String? ?? '',
      holderName: data['holderName'] as String? ?? '',
      isPrimary: data['isPrimary'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'brand': brand,
        'last4': last4,
        'expMonth': expMonth,
        'expYear': expYear,
        'holderName': holderName,
        'isPrimary': isPrimary,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      };
}

/// Service handling real Firestore backend for enterprise payment methods.
class EnterprisePaymentMethodService {
  EnterprisePaymentMethodService._internal();
  static final EnterprisePaymentMethodService instance = EnterprisePaymentMethodService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Streams list of saved payment methods for enterprise from `enterprises/{uid}/payment_methods`.
  Stream<List<PaymentMethodData>> streamPaymentMethods([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('payment_methods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => PaymentMethodData.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Streams the primary/default payment method for enterprise.
  Stream<PaymentMethodData?> streamPrimaryPaymentMethod([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(null);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('payment_methods')
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final docs = snap.docs.map((d) => PaymentMethodData.fromFirestore(d.id, d.data())).toList();
      return docs.firstWhere((p) => p.isPrimary, orElse: () => docs.first);
    });
  }

  /// Saves a new payment method to `enterprises/{uid}/payment_methods` in Firestore.
  Future<bool> savePaymentMethod({
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String holderName,
    String? uid,
  }) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final cleanCard = cardNumber.replaceAll(RegExp(r'\s+'), '');
      final last4 = cleanCard.length >= 4 ? cleanCard.substring(cleanCard.length - 4) : cleanCard;
      final brand = detectCardBrand(cleanCard);

      final docRef = _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('payment_methods')
          .doc();

      final paymentData = PaymentMethodData(
        id: docRef.id,
        brand: brand,
        last4: last4,
        expMonth: expMonth.trim(),
        expYear: expYear.trim(),
        holderName: holderName.trim(),
        isPrimary: true,
        createdAt: DateTime.now(),
      );

      await docRef.set(paymentData.toFirestore());

      // Update main enterprise doc with quick reference for billing summary
      await _firestore.collection('enterprises').doc(targetUid).set({
        'paymentMethod': '$brand (•••• $last4)',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint("[EnterprisePaymentMethodService] Error saving payment method: $e");
      return false;
    }
  }

  /// Removes a payment method from Firestore.
  Future<bool> deletePaymentMethod(String paymentMethodId, [String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('payment_methods')
          .doc(paymentMethodId)
          .delete();
      return true;
    } catch (e) {
      debugPrint("[EnterprisePaymentMethodService] Error deleting payment method: $e");
      return false;
    }
  }

  /// Detects card brand based on card number prefixes.
  static String detectCardBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith(RegExp(r'^5[1-5]')) || number.startsWith(RegExp(r'^2[2-7]'))) return 'Mastercard';
    if (number.startsWith(RegExp(r'^3[47]'))) return 'American Express';
    if (number.startsWith('6011') || number.startsWith('65')) return 'Discover';
    return 'Credit Card';
  }
}
