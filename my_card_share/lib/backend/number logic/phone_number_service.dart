// lib/backend/number logic/phone_number_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PhoneValidationModel {
  final bool isValid;
  final String cleanDigits;
  final int digitCount;
  final String? countryCode;
  final String formattedNumber;
  final String? errorMessage;

  PhoneValidationModel({
    required this.isValid,
    required this.cleanDigits,
    required this.digitCount,
    this.countryCode,
    required this.formattedNumber,
    this.errorMessage,
  });

  factory PhoneValidationModel.validateLocal(
    String input, {
    String defaultCountryCode = "+91",
    bool required = false,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      if (required) {
        return PhoneValidationModel(
          isValid: false,
          cleanDigits: '',
          digitCount: 0,
          formattedNumber: '',
          errorMessage: 'Phone number is required',
        );
      }
      return PhoneValidationModel(
        isValid: true,
        cleanDigits: '',
        digitCount: 0,
        countryCode: defaultCountryCode,
        formattedNumber: '',
        errorMessage: null,
      );
    }

    final cleanDigits = trimmed.replaceAll(RegExp(r'\D'), '');

    String countryCode = defaultCountryCode;
    String nationalNumber = cleanDigits;

    // Resolve country code prefix if present
    if (cleanDigits.length == 10) {
      nationalNumber = cleanDigits;
    } else if (cleanDigits.length == 11 && cleanDigits.startsWith('0')) {
      countryCode = defaultCountryCode;
      nationalNumber = cleanDigits.substring(1);
    } else if (cleanDigits.length == 12 && cleanDigits.startsWith('91')) {
      countryCode = '+91';
      nationalNumber = cleanDigits.substring(2);
    } else if (trimmed.startsWith('+91') && cleanDigits.startsWith('91')) {
      countryCode = '+91';
      nationalNumber = cleanDigits.substring(2);
    } else if (trimmed.startsWith('+1') && cleanDigits.startsWith('1')) {
      countryCode = '+1';
      nationalNumber = cleanDigits.substring(1);
    } else if (trimmed.startsWith('+44') && cleanDigits.startsWith('44')) {
      countryCode = '+44';
      nationalNumber = cleanDigits.substring(2);
    }

    // 🚨 STRICT 10-DIGIT ENFORCEMENT:
    // Phone number MUST be exactly 10 digits. Anything else is rejected.
    if (nationalNumber.length != 10) {
      return PhoneValidationModel(
        isValid: false,
        cleanDigits: cleanDigits,
        digitCount: nationalNumber.length,
        formattedNumber: trimmed,
        errorMessage: nationalNumber.length < 10
            ? 'Phone number must be exactly 10 digits (Entered: ${nationalNumber.length})'
            : 'Phone number cannot exceed 10 digits (Entered: ${nationalNumber.length})',
      );
    }

    // Format clean display: e.g. +91 97290 41234
    final formatted = '$countryCode ${nationalNumber.substring(0, 5)} ${nationalNumber.substring(5)}';

    return PhoneValidationModel(
      isValid: true,
      cleanDigits: nationalNumber,
      digitCount: 10,
      countryCode: countryCode,
      formattedNumber: formatted,
      errorMessage: null,
    );
  }

  factory PhoneValidationModel.fromJson(Map<String, dynamic> json) {
    return PhoneValidationModel(
      isValid: json['isValid'] ?? false,
      cleanDigits: json['cleanDigits'] ?? '',
      digitCount: json['digitCount'] ?? 0,
      countryCode: json['countryCode'],
      formattedNumber: json['formattedNumber'] ?? '',
      errorMessage: json['errorMessage'],
    );
  }
}

class PhoneNumberSyncService {
  static const String _syncEndpoint = 'https://digitalbusinesscloudcard.com/api/sync/number-logic';

  /// Live validation with Next.js web backend
  static Future<PhoneValidationModel> validateWithBackend(String phone) async {
    try {
      final response = await http.post(
        Uri.parse(_syncEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phone,
          'action': 'validate',
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return PhoneValidationModel.fromJson(data['data']);
      } else {
        return PhoneValidationModel(
          isValid: false,
          cleanDigits: phone.replaceAll(RegExp(r'\D'), ''),
          digitCount: phone.replaceAll(RegExp(r'\D'), '').length,
          formattedNumber: phone,
          errorMessage: data['error']?['message'] ?? 'Invalid phone number',
        );
      }
    } catch (e) {
      // Offline fallback to local validator
      return PhoneValidationModel.validateLocal(phone);
    }
  }

  /// Syncs validated phone number directly into User's Digital Card
  static Future<bool> saveCardPhone({
    required String cardId,
    required String phone,
    String? token,
  }) async {
    final validation = PhoneValidationModel.validateLocal(phone);
    if (!validation.isValid) {
      throw Exception(validation.errorMessage);
    }

    final response = await http.post(
      Uri.parse(_syncEndpoint),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'phone': phone,
        'action': 'save_card_phone',
        'cardId': cardId,
      }),
    );

    final data = json.decode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }
}
