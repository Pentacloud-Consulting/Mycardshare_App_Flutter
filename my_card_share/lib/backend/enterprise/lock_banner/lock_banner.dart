import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Represents the locked brand banner state for an enterprise.
class LockedBannerData {
  final String enterpriseUid;
  final String bannerUrl;
  final bool isLocked;
  final DateTime lockedAt;
  final String lockedBy;

  LockedBannerData({
    required this.enterpriseUid,
    required this.bannerUrl,
    required this.isLocked,
    required this.lockedAt,
    required this.lockedBy,
  });

  factory LockedBannerData.fromFirestore(Map<String, dynamic> data) {
    return LockedBannerData(
      enterpriseUid: data['enterpriseUid'] ?? '',
      bannerUrl: data['lockedBannerUrl'] ?? '',
      isLocked: data['bannerLocked'] ?? false,
      lockedAt: (data['bannerLockedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lockedBy: data['bannerLockedBy'] ?? '',
    );
  }
}

/// Result of a banner upload/lock operation.
class BannerLockResult {
  final bool isSuccess;
  final String message;
  final String? bannerUrl;

  const BannerLockResult({
    required this.isSuccess,
    required this.message,
    this.bannerUrl,
  });

  factory BannerLockResult.error(String message) =>
      BannerLockResult(isSuccess: false, message: message);
}

/// LockBannerService handles:
///   1. Picking a banner image from gallery
///   2. Uploading it to Firebase Storage under enterprise_banners/{uid}/banner.jpg
///   3. Saving the URL + lock status in Firestore enterprises/{uid}
///   4. Providing a real-time stream of the locked banner for employees
class LockBannerService {
  LockBannerService._internal();
  static final LockBannerService instance = LockBannerService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  Future<BannerLockResult> pickAndUploadBanner({bool lockAfterUpload = true}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return BannerLockResult.error('Not authenticated. Please log in.');

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1400,
        maxHeight: 500,
      );
      if (picked == null) return BannerLockResult.error('No image selected.');

      debugPrint('[LockBannerService] Image picked: ${picked.path}');

      final storageRef = _storage
          .ref()
          .child('enterprise_banners')
          .child(uid)
          .child('banner.jpg');

      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        uploadTask = storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        uploadTask = storageRef.putFile(File(picked.path), SettableMetadata(contentType: 'image/jpeg'));
      }

      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('[LockBannerService] Uploaded banner for $uid -> $downloadUrl');

      await _firestore.collection('enterprises').doc(uid).set({
        'lockedBannerUrl': downloadUrl,
        'bannerLocked': lockAfterUpload,
        'bannerLockedAt': FieldValue.serverTimestamp(),
        'bannerLockedBy': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return BannerLockResult(
        isSuccess: true,
        message: lockAfterUpload
            ? 'Banner uploaded and locked for all employees!'
            : 'Banner uploaded successfully.',
        bannerUrl: downloadUrl,
      );
    } on FirebaseException catch (e) {
      debugPrint('[LockBannerService] Firebase error: ${e.code} - ${e.message}');
      return BannerLockResult.error('Upload failed: ${e.message}');
    } catch (e) {
      debugPrint('[LockBannerService] Upload error: $e');
      return BannerLockResult.error('Upload failed. Please try again.');
    }
  }

  Future<BannerLockResult> setLocked({required bool locked}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return BannerLockResult.error('Not authenticated.');

    try {
      await _firestore.collection('enterprises').doc(uid).set({
        'bannerLocked': locked,
        'bannerLockedAt': FieldValue.serverTimestamp(),
        'bannerLockedBy': uid,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[LockBannerService] Banner lock set to $locked for $uid');

      return BannerLockResult(
        isSuccess: true,
        message: locked
            ? 'Banner locked for all employees.'
            : 'Banner unlocked - employees can now customize.',
      );
    } catch (e) {
      debugPrint('[LockBannerService] setLocked error: $e');
      return BannerLockResult.error('Could not update lock state.');
    }
  }

  Future<BannerLockResult> removeBanner() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return BannerLockResult.error('Not authenticated.');

    try {
      try {
        await _storage
            .ref()
            .child('enterprise_banners')
            .child(uid)
            .child('banner.jpg')
            .delete();
      } catch (_) {}

      await _firestore.collection('enterprises').doc(uid).set({
        'lockedBannerUrl': null,
        'bannerLocked': false,
        'bannerLockedAt': null,
        'bannerLockedBy': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('[LockBannerService] Banner removed for enterprise $uid');

      return const BannerLockResult(isSuccess: true, message: 'Banner removed successfully.');
    } catch (e) {
      debugPrint('[LockBannerService] removeBanner error: $e');
      return BannerLockResult.error('Could not remove banner.');
    }
  }

  Future<LockedBannerData?> fetchBanner(String enterpriseUid) async {
    try {
      final doc = await _firestore.collection('enterprises').doc(enterpriseUid).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      if (data['lockedBannerUrl'] == null) return null;
      return LockedBannerData.fromFirestore({...data, 'enterpriseUid': enterpriseUid});
    } catch (e) {
      debugPrint('[LockBannerService] fetchBanner error: $e');
      return null;
    }
  }

  Stream<LockedBannerData?> bannerStream(String enterpriseUid) {
    return _firestore
        .collection('enterprises')
        .doc(enterpriseUid)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      final data = snap.data()!;
      if (data['lockedBannerUrl'] == null) return null;
      return LockedBannerData.fromFirestore({...data, 'enterpriseUid': enterpriseUid});
    });
  }

  Future<bool> isBannerLockedForEnterprise(String enterpriseUid) async {
    try {
      final doc = await _firestore.collection('enterprises').doc(enterpriseUid).get();
      return (doc.data()?['bannerLocked'] as bool?) ?? false;
    } catch (_) {
      return false;
    }
  }
}
