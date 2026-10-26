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

  factory PhoneValidationModel.validateLocal(String input, {String defaultCountryCode = "+91"}) {
    final cleanDigits = input.replaceAll(RegExp(r'\D'), '');

    // 1. Less than 10 digits check (Fixes 9729041 bug)
    if (cleanDigits.length < 10) {
      return PhoneValidationModel(
        isValid: false,
        cleanDigits: cleanDigits,
        digitCount: cleanDigits.length,
        formattedNumber: input,
        errorMessage: 'Mobile number must be at least 10 digits (Entered: ${cleanDigits.length})',
      );
    }

    // 2. Maximum 15 digits check (ITU E.164 standard)
    if (cleanDigits.length > 15) {
      return PhoneValidationModel(
        isValid: false,
        cleanDigits: cleanDigits,
        digitCount: cleanDigits.length,
        formattedNumber: input,
        errorMessage: 'Mobile number cannot exceed 15 digits',
      );
    }

    String countryCode = defaultCountryCode;
    String nationalNumber = cleanDigits;

    if (cleanDigits.length == 10) {
      nationalNumber = cleanDigits;
    } else if (cleanDigits.length == 12 && cleanDigits.startsWith('91')) {
      countryCode = '+91';
      nationalNumber = cleanDigits.substring(2);
    }

    // Format clean display: e.g. +91 97290 41234
    final formatted = nationalNumber.length >= 5
        ? '$countryCode ${nationalNumber.substring(0, 5)} ${nationalNumber.substring(5)}'
        : '$countryCode $nationalNumber';

    return PhoneValidationModel(
      isValid: true,
      cleanDigits: cleanDigits,
      digitCount: cleanDigits.length,
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
