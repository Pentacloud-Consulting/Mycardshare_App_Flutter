import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../individual/previews/individual_metrics_store.dart';

/// Real Analytics & Metrics Model for Employee Home Dashboard (Image 2)
class EmployeeHomeStats {
  final int views;
  final String viewsTrend;
  final int leads;
  final String leadsTrend;
  final int scans;
  final String scansTrend;

  const EmployeeHomeStats({
    this.views = 0,
    this.viewsTrend = "+0% this week",
    this.leads = 0,
    this.leadsTrend = "+0% this week",
    this.scans = 0,
    this.scansTrend = "+0% this week",
  });
}

/// Real Backend Service in `lib/backend/employee_join/home/`
/// Handles real-time Views, Leads, and Scans count & trend fetching for joined Employees.
class EmployeeStatsBackendService extends ChangeNotifier {
  EmployeeStatsBackendService._internal() {
    _initMetricsSync();
  }
  static final EmployeeStatsBackendService instance = EmployeeStatsBackendService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmployeeHomeStats _stats = const EmployeeHomeStats();
  bool _isLoading = false;

  EmployeeHomeStats get stats => _stats;
  int get views => _stats.views;
  int get leads => _stats.leads;
  int get scans => _stats.scans;
  String get viewsTrend => _stats.viewsTrend;
  String get leadsTrend => _stats.leadsTrend;
  String get scansTrend => _stats.scansTrend;
  bool get isLoading => _isLoading;

  void _initMetricsSync() {
    IndividualMetricsStore.instance.addListener(() {
      _syncFromIndividualMetrics();
    });

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadEmployeeStats();
      }
    });
  }

  void _syncFromIndividualMetrics() {
    final store = IndividualMetricsStore.instance;
    _stats = EmployeeHomeStats(
      views: store.metrics.views,
      viewsTrend: store.metrics.viewsTrend,
      leads: store.metrics.leads,
      leadsTrend: store.metrics.leadsTrend,
      scans: store.metrics.scans,
      scansTrend: store.metrics.scansTrend,
    );
    notifyListeners();
  }

  /// Loads real employee views, leads, scans from Firestore & stores
  Future<void> loadEmployeeStats([String? customUid]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final targetUid = customUid ?? _auth.currentUser?.uid;

      if (targetUid != null && targetUid.isNotEmpty) {
        // Hydrate from IndividualMetricsStore first
        await IndividualMetricsStore.instance.loadMetrics(targetUid);
        _syncFromIndividualMetrics();

        // Check Firestore employee_analytics or user doc for updated real counts
        try {
          final docSnap = await _firestore
              .collection('users')
              .doc(targetUid)
              .collection('analytics')
              .doc('overview')
              .get();

          if (docSnap.exists && docSnap.data() != null) {
            final data = docSnap.data()!;
            final realViews = (data['views'] as num?)?.toInt() ?? _stats.views;
            final realLeads = (data['leads'] as num?)?.toInt() ?? _stats.leads;
            final realScans = (data['scans'] as num?)?.toInt() ?? _stats.scans;
            final vTrend = data['viewsTrend'] as String? ?? _stats.viewsTrend;
            final lTrend = data['leadsTrend'] as String? ?? _stats.leadsTrend;
            final sTrend = data['scansTrend'] as String? ?? _stats.scansTrend;

            _stats = EmployeeHomeStats(
              views: realViews,
              viewsTrend: vTrend,
              leads: realLeads,
              leadsTrend: lTrend,
              scans: realScans,
              scansTrend: sTrend,
            );
          }
        } catch (e) {
          debugPrint('[EmployeeStatsBackendService] Firestore analytics note: $e');
        }
      }
    } catch (e) {
      debugPrint('[EmployeeStatsBackendService] Error loading employee stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Increment stats dynamically when card is viewed, scanned, or lead added
  Future<void> recordView() async {
    final uid = _auth.currentUser?.uid ?? 'emp_1';
    final store = IndividualMetricsStore.instance;
    await store.incrementViews(uid);
    _syncFromIndividualMetrics();
  }

  Future<void> recordScan() async {
    final uid = _auth.currentUser?.uid ?? 'emp_1';
    final store = IndividualMetricsStore.instance;
    await store.incrementScans(uid);
    _syncFromIndividualMetrics();
  }

  Future<void> recordLead() async {
    final uid = _auth.currentUser?.uid ?? 'emp_1';
    final store = IndividualMetricsStore.instance;
    await store.incrementLeads(uid);
    _syncFromIndividualMetrics();
  }
}
