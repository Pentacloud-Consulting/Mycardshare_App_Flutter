import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Cloud Upload Service for uploading avatars, cover banners, and company logos
/// to the Next.js cloud sync endpoint (/api/sync/cloud-upload) with Firebase Storage
/// and MongoDB automatic synchronization.
class CloudUploadService {
  CloudUploadService._internal();
  static final CloudUploadService instance = CloudUploadService._internal();

  static const String baseUrl = "https://mycardshare.com";

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. UPLOAD IMAGE FILE (Avatar / Banner / Company Logo) via Multipart Form-Data
  static Future<String?> uploadImageFile({
    required File imageFile,
    required String category, // "avatar" | "banner" | "logo"
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse("$baseUrl/api/sync/cloud-upload");
      var request = http.MultipartRequest("POST", uri);
      request.headers.addAll(headers);
      request.fields["category"] = category;
      request.files.add(await http.MultipartFile.fromPath(
        "file",
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final publicUrl = json["data"]?["url"] ?? json["data"]?["publicUrl"] ?? json["url"];
        debugPrint("[CloudUploadService] Successfully uploaded to Cloud: $publicUrl");
        return publicUrl as String?;
      } else {
        debugPrint("[CloudUploadService] Server returned status ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      debugPrint("[CloudUploadService] Image upload error: $e");
    }
    return null;
  }

  /// 2. UPLOAD BASE64 (e.g. from Web, Image Cropper or Camera Snapshot)
  static Future<String?> uploadBase64Image({
    required String base64String,
    required String category, // "avatar" | "banner" | "logo"
  }) async {
    try {
      final headers = await _getHeaders();
      headers["Content-Type"] = "application/json";

      final cleanBase64 = base64String.contains(",")
          ? base64String.split(",").last
          : base64String;

      final response = await http.post(
        Uri.parse("$baseUrl/api/sync/cloud-upload"),
        headers: headers,
        body: jsonEncode({
          "imageBase64": cleanBase64,
          "category": category,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final publicUrl = json["data"]?["url"] ?? json["data"]?["publicUrl"] ?? json["url"];
        debugPrint("[CloudUploadService] Base64 image uploaded: $publicUrl");
        return publicUrl as String?;
      } else {
        debugPrint("[CloudUploadService] Base64 upload failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("[CloudUploadService] Base64 Upload Error: $e");
    }
    return null;
  }
}
