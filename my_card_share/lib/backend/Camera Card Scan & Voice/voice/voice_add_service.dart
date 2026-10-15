import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../employee_join/home/employee_home_backend.dart';
import '../camera/camera_card_scan_service.dart';

class VoiceAddService {
  VoiceAddService._internal();
  static final VoiceAddService instance = VoiceAddService._internal();

  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// Sends spoken transcript to backend Gemini NLP AI (/api/sync/voice-add)
  static Future<ExtractedCardContact> extractFromSpokenTranscript({
    required String transcript,
    bool saveToVault = true,
  }) async {
    final cleanTranscript = transcript.trim();
    final empBackend = EmployeeHomeBackendService.instance;
    final isEmployee = empBackend.companyName.isNotEmpty &&
        empBackend.companyName != 'Enterprise Workspace';
    final role = isEmployee ? 'employee' : 'individual';
    final enterpriseId = isEmployee ? empBackend.enterpriseUid : null;

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/api/sync/voice-add"),
        headers: headers,
        body: jsonEncode({
          "transcript": cleanTranscript,
          "saveToVault": saveToVault,
          "role": role,
          "enterpriseId": enterpriseId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final extracted = data["data"]?["extracted"] ?? data["extracted"] ?? data["data"];
        if (extracted is Map<String, dynamic>) {
          debugPrint("[VoiceAddService] Successfully parsed voice contact via AI NLP: ${extracted['fullName']}");
          return ExtractedCardContact.fromJson(extracted);
        }
      } else {
        debugPrint("[VoiceAddService] API returned ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("[VoiceAddService] Exception in AI Voice Add: $e");
    }

    // Dynamic NLP Fallback (Extract real details from spoken text without mock hardcoding)
    return _parseTranscriptLocally(cleanTranscript);
  }

  /// Local dynamic parser fallback if network is temporarily unreachable
  static ExtractedCardContact _parseTranscriptLocally(String text) {
    String name = 'Spoken Contact';
    String phone = '';
    String email = '';
    String company = '';
    String title = '';

    // Regex email match
    final emailMatch = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').firstMatch(text);
    if (emailMatch != null) email = emailMatch.group(0) ?? '';

    // Regex phone match
    final phoneMatch = RegExp(r'(?:\+?[\d\s-]{10,15})').firstMatch(text);
    if (phoneMatch != null) phone = phoneMatch.group(0)?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';

    // Extract name heuristically from common patterns: "Save [Name]", "Add [Name]", "Contact [Name]"
    final nameRegex = RegExp(r'(?:save|add|this is|contact|meet|name is)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)', caseSensitive: false);
    final nameMatch = nameRegex.firstMatch(text);
    if (nameMatch != null && nameMatch.groupCount >= 1) {
      name = nameMatch.group(1)?.trim() ?? 'Spoken Contact';
    } else {
      final words = text.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.isNotEmpty && words.length >= 2) {
        name = '${words[0]} ${words[1]}';
      }
    }

    // Extract company: "at [Company]", "from [Company]"
    final companyRegex = RegExp(r'(?:at|from|with)\s+([A-Za-z0-9]+(?:\s+[A-Za-z0-9]+)?)', caseSensitive: false);
    final compMatch = companyRegex.firstMatch(text);
    if (compMatch != null && compMatch.groupCount >= 1) {
      company = compMatch.group(1)?.trim() ?? '';
    }

    return ExtractedCardContact(
      id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name,
      jobTitle: title,
      company: company,
      email: email,
      phone: phone,
      notes: text,
      tag: 'Voice',
    );
  }
}
