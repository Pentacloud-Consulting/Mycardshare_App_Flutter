import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api_service.dart';

/// Data model representing Card Publish State
class PublishStatusData {
  final bool isPublished;
  final String cardStatus; // 'Published' or 'Unpublished'
  final DateTime updatedAt;

  PublishStatusData({
    this.isPublished = true,
    this.cardStatus = 'Published',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  PublishStatusData copyWith({
    bool? isPublished,
    String? cardStatus,
    DateTime? updatedAt,
  }) {
    return PublishStatusData(
      isPublished: isPublished ?? this.isPublished,
      cardStatus: cardStatus ?? this.cardStatus,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'isPublished': isPublished,
        'cardStatus': cardStatus,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory PublishStatusData.fromJson(Map<String, dynamic> json) {
    final statusStr = json['cardStatus'] as String?;
    final isPubBool = json['isPublished'] as bool?;
    final resolvedIsPub = isPubBool ?? (statusStr != 'Unpublished');
    return PublishStatusData(
      isPublished: resolvedIsPub,
      cardStatus: resolvedIsPub ? 'Published' : 'Unpublished',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Production-Grade Backend Service managing real digital card Publish & Unpublish actions.
/// Dual-writes to Firestore (`users/$uid`) and API backend, and reactively notifies UI listeners.
class PublishUnpublishService extends ChangeNotifier {
  PublishUnpublishService._internal();
  static final PublishUnpublishService instance = PublishUnpublishService._internal();

  bool _isPublished = true;
  String _cardStatus = 'Published';
  bool _isLoading = false;
  String _currentUid = '';

  bool get isPublished => _isPublished;
  String get cardStatus => _cardStatus;
  bool get isLoading => _isLoading;
  String get currentUid => _currentUid;
  String get formattedStatus => _isPublished ? "Published" : "Unpublished";

  /// Load publish status from Firestore for the given user UID
  Future<void> loadPublishStatus([String? uid]) async {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    if (targetUid.isEmpty) return;

    _currentUid = targetUid;
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(targetUid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final bool? isPub = data['isPublished'] as bool?;
        final String? statusStr = data['cardStatus'] as String?;

        if (isPub != null) {
          _isPublished = isPub;
        } else if (statusStr != null) {
          _isPublished = statusStr.toLowerCase() == 'published';
        } else {
          _isPublished = true;
        }
        _cardStatus = _isPublished ? 'Published' : 'Unpublished';
      }
    } catch (e) {
      debugPrint('[PublishUnpublishService] Error loading publish status from Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update and sync publish status to Firestore and Backend API
  Future<bool> setPublishStatus({
    required String uid,
    required bool published,
  }) async {
    final targetUid = uid.isNotEmpty ? uid : (FirebaseAuth.instance.currentUser?.uid ?? '');
    
    // Update local reactive state immediately for snappy UI feel
    _isPublished = published;
    _cardStatus = published ? 'Published' : 'Unpublished';
    _currentUid = targetUid;
    notifyListeners();

    if (targetUid.isEmpty) {
      debugPrint('[PublishUnpublishService] Warning: UID is empty, local state updated but Firestore sync skipped.');
      return true;
    }

    try {
      // 1. Sync to Firestore document under users collection
      await FirebaseFirestore.instance.collection('users').doc(targetUid).set(
        {
          'isPublished': published,
          'cardStatus': _cardStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[PublishUnpublishService] Updated publish status to $published ($cardStatus) in Firestore for UID: $targetUid');

      // 2. Dual-write sync to MongoDB backend via API endpoint (fire-and-forget background patch)
      _syncToApiBackground(published);

      return true;
    } catch (e) {
      debugPrint('[PublishUnpublishService] Firestore sync error: $e');
      return false;
    }
  }

  /// Toggle published state between Published and Unpublished
  Future<bool> togglePublishStatus(String uid) async {
    return await setPublishStatus(
      uid: uid,
      published: !_isPublished,
    );
  }

  /// Fire-and-forget background patch to REST API
  void _syncToApiBackground(bool published) {
    IndividualApiService.patch('/api/cards', {
      'cardStatus': published ? 'Published' : 'Unpublished',
      'isPublished': published,
    }).then((_) {
      debugPrint('[PublishUnpublishService] API publish status patch successful');
    }).catchError((e) {
      debugPrint('[PublishUnpublishService] API publish patch skipped (offline/no backend): $e');
    });
  }
}


