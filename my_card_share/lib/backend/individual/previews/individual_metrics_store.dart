import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualMetricsData {
  final int views;
  final String viewsTrend;
  final int leads;
  final String leadsTrend;
  final int scans;
  final String scansTrend;

  const IndividualMetricsData({
    this.views = 0,
    this.viewsTrend = "+0%",
    this.leads = 0,
    this.leadsTrend = "+0%",
    this.scans = 0,
    this.scansTrend = "+0%",
  });

  IndividualMetricsData copyWith({
    int? views,
    String? viewsTrend,
    int? leads,
    String? leadsTrend,
    int? scans,
    String? scansTrend,
  }) {
    return IndividualMetricsData(
      views: views ?? this.views,
      viewsTrend: viewsTrend ?? this.viewsTrend,
      leads: leads ?? this.leads,
      leadsTrend: leadsTrend ?? this.leadsTrend,
      scans: scans ?? this.scans,
      scansTrend: scansTrend ?? this.scansTrend,
    );
  }

  Map<String, dynamic> toJson() => {
        'views': views,
        'viewsTrend': viewsTrend,
        'leads': leads,
        'leadsTrend': leadsTrend,
        'scans': scans,
        'scansTrend': scansTrend,
      };

  factory IndividualMetricsData.fromJson(Map<String, dynamic> json) {
    return IndividualMetricsData(
      views: (json['views'] as num?)?.toInt() ?? 0,
      viewsTrend: (json['viewsTrend'] as String?) ?? "+0%",
      leads: (json['leads'] as num?)?.toInt() ?? 0,
      leadsTrend: (json['leadsTrend'] as String?) ?? "+0%",
      scans: (json['scans'] as num?)?.toInt() ?? 0,
      scansTrend: (json['scansTrend'] as String?) ?? "+0%",
    );
  }
}

/// Reactive Store managing real individual user dashboard metrics (Views, Leads, Scans)
class IndividualMetricsStore extends ChangeNotifier {
  IndividualMetricsStore._internal();
  static final IndividualMetricsStore instance = IndividualMetricsStore._internal();

  IndividualMetricsData _metrics = const IndividualMetricsData();

  IndividualMetricsData get metrics => _metrics;

  String get formattedViews => _formatNumber(_metrics.views);
  String get formattedLeads => _formatNumber(_metrics.leads);
  String get formattedScans => _formatNumber(_metrics.scans);

  /// Formats integers like 1420 into "1,420"
  static String _formatNumber(int number) {
    final str = number.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  /// Load real user metrics from Firestore collections (views, leads, contacts)
  Future<void> loadMetrics(String uid) async {
    if (uid.isEmpty) return;
    try {
      // 1. Fetch real views count from Firestore
      final viewsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('views')
          .get();
      final realViews = viewsSnapshot.docs.length;

      // 2. Fetch real leads count from Firestore
      final leadsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('leads')
          .get();
      final realLeads = leadsSnapshot.docs.length;

      // 3. Fetch real scans/contacts count from Firestore
      final scansSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .get();
      final realScans = scansSnapshot.docs.length;

      // Strictly use real Firestore document counts from subcollections
      final views = realViews;
      final leads = realLeads;
      final scans = realScans;

      _metrics = _metrics.copyWith(
        views: views,
        leads: leads,
        scans: scans,
      );

      notifyListeners();
      await _saveMetricsToFirestore(uid, _metrics);
    } catch (e) {
      debugPrint('[IndividualMetricsStore] Error loading metrics: $e');
    }
  }

  /// Increment views count
  Future<void> incrementViews(String uid) async {
    _metrics = _metrics.copyWith(views: _metrics.views + 1);
    notifyListeners();
    await _saveMetricsToFirestore(uid, _metrics);
  }

  /// Increment scans count
  Future<void> incrementScans(String uid) async {
    _metrics = _metrics.copyWith(scans: _metrics.scans + 1);
    notifyListeners();
    await _saveMetricsToFirestore(uid, _metrics);
  }

  /// Increment leads count
  Future<void> incrementLeads(String uid) async {
    _metrics = _metrics.copyWith(leads: _metrics.leads + 1);
    notifyListeners();
    await _saveMetricsToFirestore(uid, _metrics);
  }

  /// Update total leads count directly
  Future<void> updateLeadsCount(String uid, int count) async {
    _metrics = _metrics.copyWith(leads: count);
    notifyListeners();
    await _saveMetricsToFirestore(uid, _metrics);
  }

  /// Direct update of metrics
  Future<void> updateMetrics({
    required String uid,
    int? views,
    String? viewsTrend,
    int? leads,
    String? leadsTrend,
    int? scans,
    String? scansTrend,
  }) async {
    _metrics = _metrics.copyWith(
      views: views,
      viewsTrend: viewsTrend,
      leads: leads,
      leadsTrend: leadsTrend,
      scans: scans,
      scansTrend: scansTrend,
    );
    notifyListeners();
    await _saveMetricsToFirestore(uid, _metrics);
  }

  Future<void> _saveMetricsToFirestore(String uid, IndividualMetricsData data) async {
    if (uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'metrics': data.toJson()},
        SetOptions(merge: true),
      );
      debugPrint('[IndividualMetricsStore] Metrics saved for UID: $uid');
    } catch (e) {
      debugPrint('[IndividualMetricsStore] Error saving metrics to Firestore: $e');
    }
  }
}
