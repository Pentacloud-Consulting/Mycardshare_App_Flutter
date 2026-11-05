import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Comprehensive service managing Company Brochure / Catalog / Document operations:
/// - Document picking (.pdf, .doc, .docx, images)
/// - Uploading to Firebase Storage under `brochures/{uid}/`
/// - Storing metadata in Firestore & syncing to MongoDB
/// - Viewing, downloading, and sharing brochures
class BrochureService {
  BrochureService._internal();
  static final BrochureService instance = BrochureService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Picks a document file (PDF, DOC, DOCX, PNG, JPG) from the device
  Future<PlatformFile?> pickBrochureFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Limit to 20MB
        if (file.size > 20 * 1024 * 1024) {
          throw Exception('File size exceeds 20MB limit. Please choose a smaller file.');
        }
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('[BrochureService] pickBrochureFile error: $e');
      rethrow;
    }
  }

  /// Uploads the picked file to Firebase Storage under `brochures/{uid}/{cleanFileName}`
  /// and returns the download URL.
  Future<String> uploadBrochure({
    required PlatformFile file,
    required String uid,
    Function(double progress)? onProgress,
  }) async {
    try {
      final effectiveUid = uid.trim().isNotEmpty ? uid.trim() : currentUid;
      if (effectiveUid.isEmpty) {
        throw Exception('User UID is required to upload brochure.');
      }

      final ext = file.extension?.toLowerCase() ?? 'pdf';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = 'brochures/$effectiveUid/${timestamp}_$safeName';

      final ref = _storage.ref().child(storagePath);

      // Determine proper MIME type
      String contentType = 'application/pdf';
      if (ext == 'doc') contentType = 'application/msword';
      if (ext == 'docx') {
        contentType =
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      }
      if (ext == 'png') contentType = 'image/png';
      if (ext == 'jpg' || ext == 'jpeg') contentType = 'image/jpeg';

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'originalName': file.name,
          'uploadedBy': effectiveUid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask;
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File bytes are missing on Web.');
        }
        uploadTask = ref.putData(file.bytes!, metadata);
      } else {
        if (file.path == null) {
          throw Exception('File path is missing.');
        }
        uploadTask = ref.putFile(File(file.path!), metadata);
      }

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          }
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('[BrochureService] Uploaded brochure successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('[BrochureService] uploadBrochure error: $e');
      rethrow;
    }
  }

  /// Saves the brochure details to Firestore for the user/enterprise
  Future<bool> saveBrochureToFirestore({
    required String uid,
    required String brochureUrl,
    required String fileName,
    int? fileSize,
  }) async {
    try {
      final effectiveUid = uid.trim().isNotEmpty ? uid.trim() : currentUid;
      if (effectiveUid.isEmpty) return false;

      final brochureData = {
        'brochureUrl': brochureUrl,
        'brochureFileName': fileName,
        'brochureFileSize': fileSize ?? 0,
        'brochureUpdatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(effectiveUid)
          .set(brochureData, SetOptions(merge: true));

      debugPrint('[BrochureService] Saved brochure info to Firestore for $effectiveUid');
      return true;
    } catch (e) {
      debugPrint('[BrochureService] saveBrochureToFirestore error: $e');
      return false;
    }
  }

  /// Removes brochure from Firestore & Storage
  Future<bool> removeBrochure({
    required String uid,
    String? currentBrochureUrl,
  }) async {
    try {
      final effectiveUid = uid.trim().isNotEmpty ? uid.trim() : currentUid;
      if (effectiveUid.isEmpty) return false;

      final clearData = {
        'brochureUrl': FieldValue.delete(),
        'brochureFileName': FieldValue.delete(),
        'brochureFileSize': FieldValue.delete(),
        'brochureUpdatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(effectiveUid).update(clearData).catchError((_) {});

      if (currentBrochureUrl != null &&
          currentBrochureUrl.isNotEmpty &&
          currentBrochureUrl.contains('firebasestorage')) {
        try {
          final ref = _storage.refFromURL(currentBrochureUrl);
          await ref.delete();
        } catch (_) {}
      }

      return true;
    } catch (e) {
      debugPrint('[BrochureService] removeBrochure error: $e');
      return false;
    }
  }

  /// Opens the brochure URL in external browser / PDF viewer
  static Future<bool> openBrochure(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return false;
    try {
      final uri = Uri.parse(clean);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[BrochureService] openBrochure error: $e');
      return false;
    }
  }

  /// Shares the brochure URL via system share dialog
  static Future<void> shareBrochure({
    required String brochureUrl,
    String? companyOrUserName,
    String? ownerName,
    String? companyName,
  }) async {
    final clean = brochureUrl.trim();
    if (clean.isEmpty) return;

    final displayName = (companyOrUserName != null && companyOrUserName.isNotEmpty)
        ? companyOrUserName
        : ((companyName != null && companyName.isNotEmpty)
            ? companyName
            : (ownerName ?? ''));
    final shareText =
        '📄 Company Brochure of $displayName:\n$clean\n\nShared via My Card Share';

    await Share.share(
      shareText,
      subject: 'Brochure - $displayName',
    );
  }
}
