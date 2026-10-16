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
    String name = '';
    String phone = '';
    String email = '';
    String company = '';
    String title = '';
    String website = '';

    // 1. Regex email match
    final emailMatch = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').firstMatch(text);
    if (emailMatch != null) email = emailMatch.group(0) ?? '';

    // 2. Regex website match
    final webMatch = RegExp(r'(?:https?:\/\/)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:\/[^\s]*)?').firstMatch(text);
    if (webMatch != null && !webMatch.group(0)!.contains('@')) {
      website = webMatch.group(0) ?? '';
    }

    // 3. Regex phone match (international or local numbers)
    final phoneMatch = RegExp(r'(\+?\d{1,4}[\s-]?)?\(?\d{2,4}\)?[\s.-]?\d{3,4}[\s.-]?\d{3,4}').firstMatch(text);
    if (phoneMatch != null) {
      phone = phoneMatch.group(0)?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    }

    // 4. Role / Job Title extraction: e.g. "CEO at", "Product Designer at", "CTO", "Manager"
    final roleRegex = RegExp(r'(?:is|as|working as|role is|the)\s+([A-Za-z\s]+?)\s+(?:at|in|for|from)\b', caseSensitive: false);
    final roleMatch = roleRegex.firstMatch(text);
    if (roleMatch != null && roleMatch.groupCount >= 1) {
      title = roleMatch.group(1)?.trim() ?? '';
    } else {
      // Check standard titles
      final standardRoleRegex = RegExp(r'\b(CEO|CTO|CFO|COO|Founder|Co-Founder|Director|Manager|Lead|Designer|Developer|Engineer|Consultant|Partner|Agent|Specialist)\b', caseSensitive: false);
      final sMatch = standardRoleRegex.firstMatch(text);
      if (sMatch != null) {
        title = sMatch.group(0)?.trim() ?? '';
      }
    }

    // 5. Company extraction: "at Acme", "from Google", "works at Stripe"
    final companyRegex = RegExp(r'(?:at|from|with|for|company is)\s+([A-Za-z0-9&.\s]+?)(?:,|\.|\band\b|\bemail\b|\bphone\b|$)', caseSensitive: false);
    final compMatch = companyRegex.firstMatch(text);
    if (compMatch != null && compMatch.groupCount >= 1) {
      final cand = compMatch.group(1)?.trim() ?? '';
      if (!cand.toLowerCase().startsWith('the ') && cand.length <= 40) {
        company = cand;
      }
    }

    // 6. Name extraction:
    // Patterns: "Met John Doe", "Save John Doe", "Contact John Doe", "Name is John Doe", or first capitalized words
    final nameIntroRegex = RegExp(r'(?:save|add|this is|contact|meet|met|name is|call|called)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)', caseSensitive: false);
    final nameMatch = nameIntroRegex.firstMatch(text);
    if (nameMatch != null && nameMatch.groupCount >= 1) {
      name = nameMatch.group(1)?.trim() ?? '';
    }

    // Fallback: take first 2 clean capitalized words that aren't stop words
    if (name.isEmpty) {
      final stopWords = {'met', 'i', 'add', 'save', 'contact', 'new', 'this', 'is', 'here', 'the', 'a', 'an'};
      final words = text.replaceAll(RegExp(r'[^\w\s]'), '').split(' ').where((w) => w.trim().isNotEmpty).toList();
      final candidates = <String>[];
      for (final w in words) {
        if (!stopWords.contains(w.toLowerCase()) && w.length > 1) {
          candidates.add(w);
          if (candidates.length == 2) break;
        }
      }
      if (candidates.isNotEmpty) {
        name = candidates.map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
      }
    }

    if (name.isEmpty) name = 'Spoken Contact';
    if (company.isEmpty) company = 'Independent';
    if (title.isEmpty) title = 'Contact';

    return ExtractedCardContact(
      id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name,
      jobTitle: title,
      company: company,
      email: email,
      phone: phone,
      website: website,
      notes: text,
      tag: 'Voice',
    );
  }
}
