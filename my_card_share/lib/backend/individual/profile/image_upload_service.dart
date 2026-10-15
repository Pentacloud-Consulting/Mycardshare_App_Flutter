import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../Cloud Image Upload/cloud_upload_service.dart';
import '../api_service.dart';

/// Central resilient image upload service for profile photos (avatars) and banners.
/// Implements a 3-tier fallback architecture:
/// 1. Firebase Storage (Primary cloud bucket: business-card-64459.firebasestorage.app)
/// 2. Next.js API Gateway (POST /api/user/upload)
/// 3. In-line Base64 Data URL (Guaranteed offline / fallback persistence in Firestore)
class ImageUploadService {
  ImageUploadService._internal();
  static final ImageUploadService instance = ImageUploadService._internal();

  /// Uploads a local file [filePath] to cloud storage.
  /// [folder] can be 'avatars' or 'banners'.
  /// Returns a persistent public URL (or data URL fallback).
  Future<String> uploadImage({
    required String filePath,
    required String folder,
    required String uid,
  }) async {
    final cleanPath = filePath.trim();
    if (cleanPath.isEmpty) return '';

    // If it's already a remote URL or base64 data URL, return as-is
    if (cleanPath.startsWith('http://') ||
        cleanPath.startsWith('https://') ||
        cleanPath.startsWith('data:image')) {
      return cleanPath;
    }

    final file = File(cleanPath);
    if (!file.existsSync()) {
      debugPrint('[ImageUploadService] File does not exist at path: $cleanPath');
      return cleanPath;
    }

    final ext = cleanPath.split('.').last.toLowerCase();
    final contentType = (ext == 'png')
        ? 'image/png'
        : (ext == 'webp')
            ? 'image/webp'
            : 'image/jpeg';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${folder}_$timestamp.$ext';

    // ── Tier 1: Next.js Cloud Sync API Gateway (/api/sync/cloud-upload) ───
    try {
      debugPrint('[ImageUploadService] Attempting CloudUploadService (/api/sync/cloud-upload)...');
      final category = folder.contains('banner')
          ? 'banner'
          : folder.contains('logo')
              ? 'logo'
              : 'avatar';
      final cloudUrl = await CloudUploadService.uploadImageFile(
        imageFile: file,
        category: category,
      );
      if (cloudUrl != null && cloudUrl.isNotEmpty && cloudUrl.startsWith('http')) {
        debugPrint('[ImageUploadService] ✅ CloudUploadService upload success: $cloudUrl');
        return cloudUrl;
      }
    } catch (cloudErr) {
      debugPrint('[ImageUploadService] Tier 1 (CloudUploadService) note: $cloudErr');
    }

    // ── Tier 2: Firebase Storage Fallback ──────────────────────────────────
    try {
      debugPrint('[ImageUploadService] Attempting Firebase Storage upload for $fileName...');
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child(folder)
          .child(fileName);

      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(contentType: contentType),
      ).timeout(const Duration(seconds: 15));

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      if (downloadUrl.isNotEmpty && downloadUrl.startsWith('http')) {
        debugPrint('[ImageUploadService] ✅ Firebase Storage upload success: $downloadUrl');
        return downloadUrl;
      }
    } catch (storageErr) {
      debugPrint('[ImageUploadService] Tier 2 (Firebase Storage) note: $storageErr');
    }

    // ── Tier 3: Next.js API Gateway (/api/user/upload) ──────────────────────
    try {
      debugPrint('[ImageUploadService] Attempting API Gateway upload...');
      final type = folder.contains('banner') ? 'banner' : 'avatar';
      final apiUrl = await IndividualApiService.uploadFile(cleanPath, type);
      if (apiUrl.isNotEmpty && apiUrl.startsWith('http')) {
        debugPrint('[ImageUploadService] ✅ API Gateway upload success: $apiUrl');
        return apiUrl;
      }
    } catch (apiErr) {
      debugPrint('[ImageUploadService] Tier 3 (API Gateway) note: $apiErr');
    }

    // ── Tier 3: In-line Base64 Data URL Fallback ────────────────────────────
    try {
      debugPrint('[ImageUploadService] Attempting Base64 Data URL fallback...');
      final bytes = await file.readAsBytes();
      if (bytes.lengthInBytes < 600 * 1024) {
        final b64 = base64Encode(bytes);
        final dataUrl = 'data:$contentType;base64,$b64';
        debugPrint('[ImageUploadService] ✅ Base64 fallback created (${bytes.lengthInBytes} bytes)');
        return dataUrl;
      }
    } catch (b64Err) {
      debugPrint('[ImageUploadService] Tier 3 (Base64) note: $b64Err');
    }

    // Worst-case: return local path
    return cleanPath;
  }
}
