import '../../backend/number logic/phone_number_service.dart';

/// Comprehensive Validator and Formatter for Contacts, Leads, and Vault entries.
class ContactValidator {
  /// Validates phone number using the central PhoneValidationModel:
  /// - If [required] is true, empty value is invalid.
  /// - Supports 10 to 15 digits (E.164 standard), strips leading 0, formats with country code.
  static String? validatePhone(String? value, {bool required = false}) {
    final validation = PhoneValidationModel.validateLocal(value ?? '', required: required);
    return validation.isValid ? null : validation.errorMessage;
  }

  /// Validates standard email address:
  /// - If [required] is true, empty value is invalid.
  /// - If not empty, strictly enforces email format (e.g. name@domain.com).
  static String? validateEmail(String? value, {bool required = false}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      if (required) {
        return "Email address is required";
      }
      return null;
    }
    final emailRegex = RegExp(r'^[\w\.\-+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return "Please enter a valid email address (e.g. name@domain.com)";
    }
    return null; // Valid
  }

  /// Formats raw digits into E.164 standard (e.g. +91 98765 43210)
  static String formatPhoneNumber(String rawNumber, {String defaultCountryCode = "+91"}) {
    if (rawNumber.trim().isEmpty) return '';
    final validation = PhoneValidationModel.validateLocal(
      rawNumber,
      defaultCountryCode: defaultCountryCode,
      required: false,
    );
    return validation.isValid ? validation.formattedNumber : rawNumber.trim();
  }
}
