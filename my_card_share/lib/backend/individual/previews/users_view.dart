import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'individual_metrics_store.dart';

class ProfileViewRecord {
  final String id;
  final String targetUid;
  final String? viewerUid;
  final String? viewerName;
  final String source; // 'qr_scan', 'nfc', 'direct_link'
  final DateTime timestamp;

  ProfileViewRecord({
    required this.id,
    required this.targetUid,
    this.viewerUid,
    this.viewerName,
    this.source = 'qr_scan',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetUid': targetUid,
        'viewerUid': viewerUid,
        'viewerName': viewerName,
        'source': source,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ProfileViewRecord.fromJson(Map<String, dynamic> json) {
    return ProfileViewRecord(
      id: json['id'] ?? '',
      targetUid: json['targetUid'] ?? '',
      viewerUid: json['viewerUid'],
      viewerName: json['viewerName'],
      source: json['source'] ?? 'qr_scan',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service to handle real profile view tracking when a user's QR card is scanned or viewed.
class UsersViewService extends ChangeNotifier {
  UsersViewService._internal();
  static final UsersViewService instance = UsersViewService._internal();

  int _realViewCount = 0;
  int get realViewCount => _realViewCount;

  /// Records a new profile view event when a user's QR card is scanned.
  /// Increments real Views count on target user's Home Dashboard box.
  Future<void> recordProfileView({
    required String targetUid,
    String? viewerName,
    String source = 'qr_scan',
  }) async {
    if (targetUid.isEmpty) return;

    try {
      final viewerUid = FirebaseAuth.instance.currentUser?.uid;
      final recordId = 'view_${DateTime.now().millisecondsSinceEpoch}';

      final record = ProfileViewRecord(
        id: recordId,
        targetUid: targetUid,
        viewerUid: viewerUid,
        viewerName: viewerName ?? 'Card Visitor',
        source: source,
      );

      // Save view record in Firestore under user's views collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('views')
          .doc(recordId)
          .set(record.toJson());

      debugPrint('[UsersViewService] Profile view recorded for $targetUid via $source');

      // Increment real Views count in IndividualMetricsStore for target user
      await IndividualMetricsStore.instance.incrementViews(targetUid);
      _realViewCount++;
      notifyListeners();
    } catch (e) {
      debugPrint('[UsersViewService] Error recording profile view: $e');
    }
  }

  /// Triggers a view event when a QR Code is scanned (Image 4 popup).
  Future<void> onQrCodeScanned({
    required String targetUid,
    String? viewerName,
  }) async {
    await recordProfileView(
      targetUid: targetUid,
      viewerName: viewerName,
      source: 'qr_scan',
    );
  }

  /// Fetches total profile views count from Firestore.
  Future<int> fetchTotalViews(String uid) async {
    if (uid.isEmpty) return 0;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('views')
          .get();

      _realViewCount = snapshot.docs.length;
      notifyListeners();
      return _realViewCount;
    } catch (e) {
      debugPrint('[UsersViewService] Error fetching views count: $e');
      return 0;
    }
  }
}
