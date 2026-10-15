import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../employee_join/home/employee_home_backend.dart';

class ExtractedCardContact {
  final String id;
  final String fullName;
  final String jobTitle;
  final String company;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String notes;
  final String tag;

  ExtractedCardContact({
    required this.id,
    required this.fullName,
    required this.jobTitle,
    required this.company,
    required this.email,
    required this.phone,
    this.website = '',
    this.address = '',
    this.notes = '',
    this.tag = 'OCR',
  });

  factory ExtractedCardContact.fromJson(Map<String, dynamic> json) {
    return ExtractedCardContact(
      id: json['id'] ?? 'scan_${DateTime.now().millisecondsSinceEpoch}',
      fullName: json['fullName'] ?? json['name'] ?? '',
      jobTitle: json['jobTitle'] ?? json['role'] ?? json['title'] ?? '',
      company: json['company'] ?? json['companyName'] ?? '',
      email: json['email'] ?? json['workEmail'] ?? '',
      phone: json['phone'] ?? json['workPhone'] ?? json['mobile'] ?? '',
      website: json['website'] ?? '',
      address: json['address'] ?? json['location'] ?? '',
      notes: json['notes'] ?? json['bio'] ?? '',
      tag: json['tag'] ?? 'OCR',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'jobTitle': jobTitle,
        'company': company,
        'email': email,
        'phone': phone,
        'website': website,
        'address': address,
        'notes': notes,
        'tag': tag,
      };
}

class CameraCardScanService {
  CameraCardScanService._internal();
  static final CameraCardScanService instance = CameraCardScanService._internal();

  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// Sends card image to backend AI Vision OCR (/api/sync/camera-card-scan)
  static Future<ExtractedCardContact?> scanCardImage({
    required File imageFile,
    bool saveToVault = true,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final empBackend = EmployeeHomeBackendService.instance;
      final isEmployee = empBackend.companyName.isNotEmpty &&
          empBackend.companyName != 'Enterprise Workspace';
      final role = isEmployee ? 'employee' : 'individual';
      final enterpriseId = isEmployee ? empBackend.enterpriseUid : null;

      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/sync/camera-card-scan"),
        headers: headers,
        body: jsonEncode({
          "image": "data:image/jpeg;base64,$base64Image",
          "saveToVault": saveToVault,
          "role": role,
          "enterpriseId": enterpriseId,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final extracted = data["data"]?["extracted"] ?? data["extracted"] ?? data["data"];
        if (extracted is Map<String, dynamic>) {
          debugPrint("[CameraCardScanService] Successfully extracted card contact via AI Vision OCR");
          return ExtractedCardContact.fromJson(extracted);
        }
      } else {
        debugPrint("[CameraCardScanService] API error ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      debugPrint("[CameraCardScanService] Exception scanning card image: $e");
    }
    return null;
  }
}
