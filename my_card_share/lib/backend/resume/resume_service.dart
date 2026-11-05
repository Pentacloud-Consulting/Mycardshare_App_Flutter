import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Comprehensive and resilient service managing Resume/CV operations:
/// - Document picking (.pdf, .doc, .docx, images)
/// - Uploading to Firebase Storage with public download URL
/// - Storing metadata in Firestore (users, enterprises, employees)
/// - Viewing, downloading, and sharing resumes
class ResumeService {
  ResumeService._internal();
  static final ResumeService instance = ResumeService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Picks a document file (PDF, DOC, DOCX, PNG, JPG) from the device
  Future<PlatformFile?> pickResumeFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        // Limit to 15MB
        if (file.size > 15 * 1024 * 1024) {
          throw Exception('File size exceeds 15MB limit. Please choose a smaller file.');
        }
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('[ResumeService] pickResumeFile error: $e');
      rethrow;
    }
  }

  /// Uploads the picked file to Firebase Storage under `resumes/{uid}/{cleanFileName}`
  /// and returns the download URL.
  Future<String> uploadResume({
    required PlatformFile file,
    required String uid,
    Function(double progress)? onProgress,
  }) async {
    try {
      final effectiveUid = uid.trim().isNotEmpty ? uid.trim() : currentUid;
      if (effectiveUid.isEmpty) {
        throw Exception('User UID is required to upload resume.');
      }

      final ext = file.extension?.toLowerCase() ?? 'pdf';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = 'resumes/$effectiveUid/${timestamp}_$safeName';

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
      debugPrint('[ResumeService] Uploaded resume successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('[ResumeService] uploadResume error: $e');
      rethrow;
    }
  }

  /// Saves the resume details to Firestore for the user/enterprise/employee
  Future<bool> saveResumeToFirestore({
    required String uid,
    required String resumeUrl,
    required String fileName,
    int? fileSize,
    String? enterpriseUid,
    String? employeeDocId,
  }) async {
    try {
      final effectiveUid = uid.trim().isNotEmpty ? uid.trim() : currentUid;
      if (effectiveUid.isEmpty) return false;

      final resumeData = {
        'resumeUrl': resumeUrl,
        'resumeFileName': fileName,
        'resumeFileSize': fileSize ?? 0,
        'resumeUpdatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Save in users/{uid}
      await _firestore
          .collection('users')
          .doc(effectiveUid)
          .set(resumeData, SetOptions(merge: true));

      // 2. If enterprise account, save in enterprises/{uid}
      try {
        final entDoc = await _firestore.collection('enterprises').doc(effectiveUid).get();
        if (entDoc.exists) {
          await _firestore
              .collection('enterprises')
              .doc(effectiveUid)
              .set(resumeData, SetOptions(merge: true));
        }
      } catch (_) {}

      // 3. If employee inside an enterprise, also save to employee doc
      if (enterpriseUid != null &&
          enterpriseUid.isNotEmpty &&
          employeeDocId != null &&
          employeeDocId.isNotEmpty) {
        try {
          await _firestore
              .collection('enterprises')
              .doc(enterpriseUid)
              .collection('employees')
              .doc(employeeDocId)
              .set(resumeData, SetOptions(merge: true));
        } catch (_) {}
      }

      debugPrint('[ResumeService] Saved resume info to Firestore for $effectiveUid');
      return true;
    } catch (e) {
      debugPrint('[ResumeService] saveResumeToFirestore error: $e');
      return false;
    }
  }

  /// Removes resume from Firestore & Storage
  Future<bool> removeResume({
    required String uid,
    String? currentResumeUrl,
    String? enterpriseUid,
    String? employeeDocId,
  }) async {
    try {
      final effectiveUid = uid.trim().isNotEmpty ? uid.trim() : currentUid;
      if (effectiveUid.isEmpty) return false;

      final clearData = {
        'resumeUrl': FieldValue.delete(),
        'resumeFileName': FieldValue.delete(),
        'resumeFileSize': FieldValue.delete(),
        'resumeUpdatedAt': FieldValue.serverTimestamp(),
      };

      // 1. Clear from users/{uid}
      await _firestore.collection('users').doc(effectiveUid).update(clearData).catchError((_) {});

      // 2. Clear from enterprises/{uid} if exists
      await _firestore
          .collection('enterprises')
          .doc(effectiveUid)
          .update(clearData)
          .catchError((_) {});

      // 3. Clear from employee doc if provided
      if (enterpriseUid != null &&
          enterpriseUid.isNotEmpty &&
          employeeDocId != null &&
          employeeDocId.isNotEmpty) {
        await _firestore
            .collection('enterprises')
            .doc(enterpriseUid)
            .collection('employees')
            .doc(employeeDocId)
            .update(clearData)
            .catchError((_) {});
      }

      // 4. Optionally remove storage file if URL is valid Firebase Storage URL
      if (currentResumeUrl != null &&
          currentResumeUrl.isNotEmpty &&
          currentResumeUrl.contains('firebasestorage')) {
        try {
          final ref = _storage.refFromURL(currentResumeUrl);
          await ref.delete();
        } catch (_) {}
      }

      return true;
    } catch (e) {
      debugPrint('[ResumeService] removeResume error: $e');
      return false;
    }
  }

  /// Opens the resume URL in external browser / PDF viewer
  static Future<bool> openResume(String url) async {
    final clean = url.trim();
    if (clean.isEmpty) return false;
    try {
      final uri = Uri.parse(clean);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[ResumeService] openResume error: $e');
      return false;
    }
  }

  /// Shares the resume URL via system share dialog
  static Future<void> shareResume({
    required String resumeUrl,
    required String candidateName,
    String? jobTitle,
  }) async {
    final clean = resumeUrl.trim();
    if (clean.isEmpty) return;

    final roleText = jobTitle != null && jobTitle.trim().isNotEmpty
        ? ' ($jobTitle)'
        : '';
    final shareText =
        '📄 Resume of $candidateName$roleText:\n$clean\n\nShared via My Card Share';

    await Share.share(
      shareText,
      subject: 'Resume - $candidateName',
    );
  }

  /// Helper to format file size in KB or MB
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
