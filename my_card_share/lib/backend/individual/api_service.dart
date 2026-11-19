import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Central HTTP service for MyCardShare API.
/// All protected requests automatically attach a fresh Firebase JWT Bearer token.
class IndividualApiService {
  IndividualApiService._internal();
  static final IndividualApiService instance = IndividualApiService._internal();

  /// Production base URL — matches the spec in Individual_Auth_Integration.md
  static const String baseUrl = 'https://mycardshare.com';

  // ─── Token Helper ─────────────────────────────────────────────────────────

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('[IndividualApiService] No authenticated Firebase user.');
    }
    // Force-refresh so the token is never expired
    final idToken = await user.getIdToken(true);
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  // ─── GET ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _getHeaders();
    debugPrint('[IndividualApiService] GET $baseUrl$endpoint');
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handle(response);
  }

  // ─── PATCH ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    debugPrint('[IndividualApiService] PATCH $baseUrl$endpoint body=$body');
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  // ─── POST ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    debugPrint('[IndividualApiService] POST $baseUrl$endpoint body=$body');
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = await _getHeaders();
    debugPrint('[IndividualApiService] DELETE $baseUrl$endpoint');
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _handle(response);
  }

  // ─── Multipart Upload (avatar / banner) ───────────────────────────────────

  /// Uploads a file via POST /api/user/upload.
  /// [type] must be "avatar" or "banner".
  /// Returns the public image URL string on success.
  static Future<String> uploadFile(String filePath, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('[IndividualApiService] Not authenticated.');
    final idToken = await user.getIdToken(true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/user/upload'),
    );
    request.headers['Authorization'] = 'Bearer $idToken';
    request.fields['type'] = type;
    // Explicitly pass MIME type so the backend image validator accepts the file.
    // Without this, fromPath() may send 'application/octet-stream' which
    // the server rejects, causing silent upload failures.
    final ext = filePath.split('.').last.toLowerCase();
    final mimeType = ext == 'png'
        ? 'image/png'
        : ext == 'webp' ? 'image/webp' : 'image/jpeg';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType.parse(mimeType),
      ),
    );

    debugPrint('[IndividualApiService] UPLOAD $filePath as $type');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = _handle(response);
    return data['data']?['url'] as String? ?? '';
  }

  /// Blazing-fast direct byte upload to POST /api/user/upload.
  /// Works flawlessly across Web, Android, iOS without disk path or CORS hangs.
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String filename,
    required String type,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('[IndividualApiService] Not authenticated.');
    final idToken = await user.getIdToken(true);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/user/upload'),
    );
    request.headers['Authorization'] = 'Bearer $idToken';
    request.fields['type'] = type;
    // Determine MIME type from filename extension for server-side validation
    String mimeType = 'application/octet-stream';
    final ext = filename.split('.').last.toLowerCase();
    if (ext == 'pdf') mimeType = 'application/pdf';
    else if (ext == 'doc') mimeType = 'application/msword';
    else if (ext == 'docx') mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    else if (ext == 'png') mimeType = 'image/png';
    else if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';
    else if (ext == 'gif') mimeType = 'image/gif';
    else if (ext == 'webp') mimeType = 'image/webp';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: MediaType.parse(mimeType),
    ));

    debugPrint('[IndividualApiService] FAST UPLOAD as ' + type + ' (' + bytes.length.toString() + ' bytes)');
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Upload timed out after 30 seconds'),
    );
    final response = await http.Response.fromStream(streamedResponse);
    final data = _handle(response);
    return data['data']?['url'] as String? ?? '';
  }

  // ─── Public (no auth) ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getPublic(String endpoint) async {
    debugPrint('[IndividualApiService] GET (public) $baseUrl$endpoint');
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handle(response);
  }

  // ─── Response Handler ─────────────────────────────────────────────────────

  static Map<String, dynamic> _handle(http.Response response) {
    debugPrint(
        '[IndividualApiService] ${response.statusCode} ${response.request?.url}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      '[IndividualApiService] API Error ${response.statusCode}: ${response.body}',
    );
  }
}


