import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Represents one traffic source entry with its real view count and percentage.
class TrafficSourceItem {
  final String name;       // Display name e.g. "QR Scan"
  final String sourceKey;  // Firestore source value e.g. 'qr_scan'
  final int count;
  final double percentage;

  const TrafficSourceItem({
    required this.name,
    required this.sourceKey,
    required this.count,
    required this.percentage,
  });
}

/// Service that reads real traffic source breakdown from Firestore views collection.
///
/// Firestore path: users/{uid}/views — each doc has a `source` field with values:
///   'qr_scan'     → "QR Scan"
///   'direct_link' → "Direct Link"
///   'email_share' → "Email Share"
///   'whatsapp'    → "WhatsApp"
///   'nfc'         → "NFC Tap"
class TrafficSourceService extends ChangeNotifier {
  TrafficSourceService._internal();
  static final TrafficSourceService instance = TrafficSourceService._internal();

  List<TrafficSourceItem> _sources = [];
  bool _isLoading = false;
  int _totalViews = 0;

  List<TrafficSourceItem> get sources => _sources;
  bool get isLoading => _isLoading;
  int get totalViews => _totalViews;

  // Source key → pretty display name mapping
  static const Map<String, String> _sourceDisplayNames = {
    'qr_scan':     'QR Scan',
    'direct_link': 'Direct Link',
    'email_share': 'Email Share',
    'whatsapp':    'WhatsApp',
    'nfc':         'NFC Tap',
    'linkedin':    'LinkedIn',
    'instagram':   'Instagram',
    'twitter':     'Twitter',
  };

  /// Fetches real traffic source breakdown from Firestore for the current user.
  Future<void> fetchTrafficSources({String? uid}) async {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (targetUid == null || targetUid.isEmpty) {
      debugPrint('[TrafficSourceService] No UID — skipping fetch');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .collection('views')
          .get();

      // Count views per source key
      final Map<String, int> sourceCounts = {};
      for (final doc in snapshot.docs) {
        final src = (doc.data()['source'] as String?) ?? 'qr_scan';
        sourceCounts[src] = (sourceCounts[src] ?? 0) + 1;
      }

      _totalViews = snapshot.docs.length;

      // Sort by count descending
      final sorted = sourceCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Build TrafficSourceItem list with real percentages
      _sources = sorted.map((entry) {
        final pct = _totalViews > 0
            ? (entry.value / _totalViews * 100).roundToDouble()
            : 0.0;
        return TrafficSourceItem(
          name: _sourceDisplayNames[entry.key] ?? _prettifyKey(entry.key),
          sourceKey: entry.key,
          count: entry.value,
          percentage: pct,
        );
      }).toList();

      debugPrint('[TrafficSourceService] Loaded ${_sources.length} sources, total=$_totalViews');
    } catch (e) {
      debugPrint('[TrafficSourceService] Error fetching traffic sources: $e');
      _sources = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Converts a raw source key like 'email_share' to 'Email Share'
  static String _prettifyKey(String key) {
    return key
        .split('_')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  /// Returns the brand color for a given source key
  static int colorForSource(String sourceKey) {
    switch (sourceKey) {
      case 'qr_scan':
        return 0xFF0066FF;
      case 'direct_link':
        return 0xFF0D9488;
      case 'email_share':
        return 0xFF16A34A;
      case 'whatsapp':
        return 0xFF25D366;
      case 'nfc':
        return 0xFF9333EA;
      case 'linkedin':
        return 0xFF0A66C2;
      case 'instagram':
        return 0xFFE1306C;
      case 'twitter':
        return 0xFF1DA1F2;
      default:
        return 0xFFF59E0B;
    }
  }
}
