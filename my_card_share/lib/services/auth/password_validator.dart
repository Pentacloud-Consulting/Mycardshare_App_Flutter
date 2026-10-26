import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Password validation result model matching website policy exactly.
class PasswordValidationResult {
  final bool minLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecialChar;
  final int score;
  final String strengthLabel;

  const PasswordValidationResult({
    required this.minLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecialChar,
    required this.score,
    required this.strengthLabel,
  });

  /// Password is valid ONLY when all 5 requirements are met
  bool get isValid =>
      minLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar;

  String? get firstErrorMessage {
    if (!minLength) return "Password must be at least 8 characters long";
    if (!hasUppercase) return "Password must contain at least one uppercase letter (A-Z)";
    if (!hasLowercase) return "Password must contain at least one lowercase letter (a-z)";
    if (!hasNumber) return "Password must contain at least one number (0-9)";
    if (!hasSpecialChar) return "Password must contain at least one special character (!@#\$%...)";
    return null;
  }

  factory PasswordValidationResult.empty() {
    return const PasswordValidationResult(
      minLength: false,
      hasUppercase: false,
      hasLowercase: false,
      hasNumber: false,
      hasSpecialChar: false,
      score: 0,
      strengthLabel: 'Weak',
    );
  }

  factory PasswordValidationResult.validate(String password) {
    if (password.isEmpty) {
      return PasswordValidationResult.empty();
    }

    final minLength = password.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final hasNum = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_+=\[\]\\\/~`]').hasMatch(password);

    int score = 0;
    if (minLength) score++;
    if (hasUpper) score++;
    if (hasLower) score++;
    if (hasNum) score++;
    if (hasSpecial) score++;

    String label = 'Weak';
    if (score == 3) {
      label = 'Fair';
    } else if (score == 4) {
      label = 'Good';
    } else if (score >= 5) {
      label = 'Strong';
    }

    return PasswordValidationResult(
      minLength: minLength,
      hasUppercase: hasUpper,
      hasLowercase: hasLower,
      hasNumber: hasNum,
      hasSpecialChar: hasSpecial,
      score: score,
      strengthLabel: label,
    );
  }
}

/// Visual Password Strength Indicator Widget with 5-segment bar & checklist.
class PasswordStrengthIndicatorWidget extends StatelessWidget {
  final PasswordValidationResult validation;
  final bool showChecklist;

  const PasswordStrengthIndicatorWidget({
    super.key,
    required this.validation,
    this.showChecklist = true,
  });

  Color _getStrengthColor() {
    if (validation.score <= 2) return const Color(0xFFEF4444); // Red
    if (validation.score == 3) return const Color(0xFFF59E0B); // Amber
    if (validation.score == 4) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFF10B981); // Green
  }

  @override
  Widget build(BuildContext context) {
    final strengthColor = _getStrengthColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // 5-Segment Strength Bar
        Row(
          children: List.generate(5, (index) {
            final isActive = validation.score > index;
            final barColor = isActive ? strengthColor : const Color(0xFFE2E8F0);

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 6),

        // Strength Label Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  "Strength: ",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  validation.strengthLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: strengthColor,
                  ),
                ),
              ],
            ),
            if (validation.isValid)
              const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 4),
                  Text(
                    "All criteria met",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Checklist of 5 rules
        if (showChecklist) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            ),
            child: Column(
              children: [
                _buildRuleRow("At least 8 characters", validation.minLength),
                _buildRuleRow("At least one uppercase letter (A-Z)", validation.hasUppercase),
                _buildRuleRow("At least one lowercase letter (a-z)", validation.hasLowercase),
                _buildRuleRow("At least one number (0-9)", validation.hasNumber),
                _buildRuleRow("At least one special character (!@#\$%...)", validation.hasSpecialChar),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRuleRow(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: met ? const Color(0xFF10B981) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: met ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: met
                ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                color: met ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                fontWeight: met ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Service connecting password logic with web backend sync endpoint
class PasswordSyncService {
  PasswordSyncService._internal();
  static final PasswordSyncService instance = PasswordSyncService._internal();

  static const String baseUrl = 'https://mycardshare.com'; // Fallback domain

  /// Sync Account Creation with backend API route (/api/sync/password-logic?action=create_account)
  Future<Map<String, dynamic>?> syncCreateAccount({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'individual' or 'enterprise'
    String? domain,
  }) async {
    try {
      final host = domain ?? baseUrl;
      final url = Uri.parse('$host/api/sync/password-logic?action=create_account');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'confirmPassword': password,
          'fullName': fullName,
          'role': role,
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (_) {
      // Return null on offline or network error, allowing client Firebase fallback
      return null;
    }
  }

  /// Sync Password Update with backend API route (/api/sync/password-logic?action=update_password)
  Future<bool> syncUpdatePassword({
    required String uid,
    required String newPassword,
    String? idToken,
    String? domain,
  }) async {
    try {
      final host = domain ?? baseUrl;
      final url = Uri.parse('$host/api/sync/password-logic?action=update_password');
      final headers = {'Content-Type': 'application/json'};
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'uid': uid,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
