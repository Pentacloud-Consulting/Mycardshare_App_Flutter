import 'publish_unpublish.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api_service.dart';

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
  String _loadedForUid = '';

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

  /// Load real user metrics — primary source: Web API, fallback: Firestore
  Future<void> loadMetrics(String uid) async {
    if (uid.isEmpty) return;

    // Reset metrics when switching to a different user to prevent stale data
    // from one account bleeding into another account's display.
    if (_loadedForUid != uid) {
      _loadedForUid = uid;
      _metrics = const IndividualMetricsData();
      notifyListeners();
    }

    try {
      // ── P0: Live Sync from Web API (/api/user/stats) ──────────────────────
      // This reads MongoDB `cards.views` which is the REAL count (123, not 17)
      try {
        final apiRes = await IndividualApiService.get('/api/user/stats')
            .timeout(const Duration(seconds: 10));
        if (apiRes['success'] == true && apiRes['data'] != null) {
          final data = apiRes['data'] as Map<String, dynamic>;
          // Web API stores real views in `views` OR `impressions` field
          final liveViews = (data['views'] as num?)?.toInt() ??
              (data['impressions'] as num?)?.toInt() ??
              (data['cardViews'] as num?)?.toInt() ??
              0;
          final liveLeads = (data['connectionsCount'] as num?)?.toInt() ??
              (data['leads'] as num?)?.toInt() ??
              0;
          final liveScans = (data['scans'] as num?)?.toInt() ?? 0;
          final viewsTrend = (data['viewsTrend'] as String?) ?? "+0%";
          final leadsTrend = (data['connectionsTrend'] as String?) ??
              (data['leadsTrend'] as String?) ??
              "+0%";
          final cardStatus = data['cardStatus'] as String?;

          // Only update if we got meaningful data (don't overwrite 123 with 0)
          _metrics = _metrics.copyWith(
            views: liveViews > 0 ? liveViews : _metrics.views,
            leads: liveLeads > 0 ? liveLeads : _metrics.leads,
            scans: liveScans > 0 ? liveScans : _metrics.scans,
            viewsTrend: viewsTrend,
            leadsTrend: leadsTrend,
          );
          notifyListeners();

          if (cardStatus != null && cardStatus.isNotEmpty) {
            PublishUnpublishService.instance.syncFromStatus(cardStatus);
          }

          // Write back to Firestore so offline reads get latest values
          _saveMetricsToFirestore(uid, _metrics);
          debugPrint('[IndividualMetricsStore] ✅ API stats: views=$liveViews, leads=$liveLeads, scans=$liveScans, cardStatus=$cardStatus');
          return;
        }
      } catch (apiErr) {
        debugPrint('[IndividualMetricsStore] /api/user/stats failed (CORS/offline), falling back to Firestore: $apiErr');
      }

      // ── P1: Firestore user doc — check ALL possible field names ──────────
      int views = 0;
      int leads = 0;
      int scans = 0;

      try {
        final uSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (uSnap.exists && uSnap.data() != null) {
          final uData = uSnap.data()!;
          final mData = uData['metrics'] as Map<String, dynamic>?;

          // Try every possible field name Web/MongoDB might write
          views = (uData['cardViews'] as num?)?.toInt() ??
              (uData['impressions'] as num?)?.toInt() ??
              (uData['views'] as num?)?.toInt() ??
              (mData?['cardViews'] as num?)?.toInt() ??
              (mData?['impressions'] as num?)?.toInt() ??
              (mData?['views'] as num?)?.toInt() ??
              0;

          leads = (uData['connectionsCount'] as num?)?.toInt() ??
              (uData['leads'] as num?)?.toInt() ??
              (mData?['leads'] as num?)?.toInt() ??
              0;

          scans = (uData['scans'] as num?)?.toInt() ??
              (mData?['scans'] as num?)?.toInt() ??
              0;

          debugPrint('[IndividualMetricsStore] Firestore user doc -> views=$views, leads=$leads, scans=$scans');
        }
      } catch (fsErr) {
        debugPrint('[IndividualMetricsStore] Firestore user doc error: $fsErr');
      }

      // ── P2: Subcollections as supplementary data ───────────────────────
      try {
        final viewsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('views')
            .get();
        if (viewsSnap.docs.length > views) views = viewsSnap.docs.length;
      } catch (_) {}

      try {
        final leadsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('leads')
            .get();
        if (leadsSnap.docs.length > leads) leads = leadsSnap.docs.length;
      } catch (_) {}

      try {
        final contactsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('contacts')
            .get();
        if (contactsSnap.docs.length > scans) scans = contactsSnap.docs.length;
      } catch (_) {}

      _metrics = _metrics.copyWith(
        views: views,
        leads: leads,
        scans: scans,
      );

      notifyListeners();
      debugPrint('[IndividualMetricsStore] Final metrics: views=$views, leads=$leads, scans=$scans');
    } catch (e) {
      debugPrint('[IndividualMetricsStore] Error loading metrics: $e');
    }
  }

  /// Increment views count
  Future<void> incrementViews(String uid) async {
    _loadedForUid = uid;
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
      final metricsPayload = data.toJson();
      // Save to users/{uid} top-level
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'metrics': metricsPayload},
        SetOptions(merge: true),
      );
      // Also write flat fields for direct reads
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'cardViews': data.views,
          'impressions': data.views,
          'views': data.views,
          'connectionsCount': data.leads,
          'leads': data.leads,
          'scans': data.scans,
        },
        SetOptions(merge: true),
      );
      // Also persist in analytics/overview subcollection for EmployeeStatsBackendService
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('analytics')
          .doc('overview')
          .set(metricsPayload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[IndividualMetricsStore] Error saving metrics to Firestore: $e');
    }
  }
}
