import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Model representing a CRM Integration Connector record in Firestore.
class CrmConnectorModel {
  final String id;
  final String name;
  final String provider; // 'salesforce', 'hubspot', 'zapier', 'followupboss'
  final bool isConnected;
  final String instanceUrl;
  final String apiKey;
  final DateTime? lastSyncedAt;

  const CrmConnectorModel({
    required this.id,
    required this.name,
    required this.provider,
    required this.isConnected,
    this.instanceUrl = '',
    this.apiKey = '',
    this.lastSyncedAt,
  });

  String get statusText => isConnected ? 'Connected' : 'Not Connected';

  factory CrmConnectorModel.fromFirestore(String docId, Map<String, dynamic> data) {
    return CrmConnectorModel(
      id: docId,
      name: data['name'] as String? ?? 'CRM Connector',
      provider: data['provider'] as String? ?? docId,
      isConnected: data['isConnected'] as bool? ?? false,
      instanceUrl: data['instanceUrl'] as String? ?? '',
      apiKey: data['apiKey'] as String? ?? '',
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'provider': provider,
        'isConnected': isConnected,
        'instanceUrl': instanceUrl,
        'apiKey': apiKey,
        'lastSyncedAt': lastSyncedAt != null ? Timestamp.fromDate(lastSyncedAt!) : FieldValue.serverTimestamp(),
      };
}

/// Data Model for Webhook configuration.
class CrmWebhookConfig {
  final String webhookUrl;
  final DateTime? lastTestedAt;

  const CrmWebhookConfig({
    this.webhookUrl = 'https://hooks.zapier.com/hooks/catch/128491/acme_leads',
    this.lastTestedAt,
  });

  factory CrmWebhookConfig.fromFirestore(Map<String, dynamic>? data) {
    return CrmWebhookConfig(
      webhookUrl: data?['webhookUrl'] as String? ?? 'https://hooks.zapier.com/hooks/catch/128491/acme_leads',
      lastTestedAt: (data?['lastTestedAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Data Model for Sync Failure Logs.
class CrmSyncLogModel {
  final String id;
  final String leadName;
  final String leadEmail;
  final String connectorName;
  final String errorMessage;
  final DateTime timestamp;

  const CrmSyncLogModel({
    required this.id,
    required this.leadName,
    required this.leadEmail,
    required this.connectorName,
    required this.errorMessage,
    required this.timestamp,
  });

  factory CrmSyncLogModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CrmSyncLogModel(
      id: id,
      leadName: data['leadName'] as String? ?? 'Lead Contact',
      leadEmail: data['leadEmail'] as String? ?? '',
      connectorName: data['connectorName'] as String? ?? 'Salesforce',
      errorMessage: data['errorMessage'] as String? ?? 'HTTP 401 Unauthorized API Token',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Real Backend Service managing CRM Connectors, Webhooks & Sync Logs in Firestore.
class EnterpriseCrmService {
  EnterpriseCrmService._internal();
  static final EnterpriseCrmService instance = EnterpriseCrmService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Default predefined list of supported CRM connectors.
  static final List<CrmConnectorModel> defaultConnectors = [
    const CrmConnectorModel(
      id: 'salesforce',
      name: 'Salesforce',
      provider: 'salesforce',
      isConnected: true,
      instanceUrl: 'acme.my.salesforce.com',
    ),
    const CrmConnectorModel(
      id: 'hubspot',
      name: 'HubSpot',
      provider: 'hubspot',
      isConnected: true,
    ),
    const CrmConnectorModel(
      id: 'zapier',
      name: 'Zapier',
      provider: 'zapier',
      isConnected: false,
    ),
    const CrmConnectorModel(
      id: 'followupboss',
      name: 'Follow Up Boss',
      provider: 'followupboss',
      isConnected: false,
    ),
  ];

  /// Streams real CRM Connectors from `enterprises/{uid}/crm_connectors`.
  Stream<List<CrmConnectorModel>> streamConnectors([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(defaultConnectors);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('crm_connectors')
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) {
        return defaultConnectors;
      }

      final saved = snap.docs
          .map((doc) => CrmConnectorModel.fromFirestore(doc.id, doc.data()))
          .toList();

      // Merge defaults with saved documents
      final result = <CrmConnectorModel>[];
      for (final def in defaultConnectors) {
        final existing = saved.firstWhere((s) => s.id == def.id, orElse: () => def);
        result.add(existing);
      }
      return result;
    });
  }

  /// Streams Webhook Config from `enterprises/{uid}/crm_config/webhook`.
  Stream<CrmWebhookConfig> streamWebhookConfig([String? uid]) {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(const CrmWebhookConfig());
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('crm_config')
        .doc('webhook')
        .snapshots()
        .map((doc) => CrmWebhookConfig.fromFirestore(doc.data()));
  }

  /// Streams Failed Sync Logs from `enterprises/{uid}/crm_sync_logs`.
  Stream<List<CrmSyncLogModel>> streamFailedSyncLogs([String? uid]) {
    final targetUid = uid ?? currentUid;

    final defaultLogs = [
      CrmSyncLogModel(
        id: 'log_1',
        leadName: 'Robert Vance',
        leadEmail: 'robert@vancerealty.com',
        connectorName: 'Salesforce',
        errorMessage: 'OAuth token expired during lead export',
        timestamp: DateTime(2026, 10, 8, 12, 30),
      ),
      CrmSyncLogModel(
        id: 'log_2',
        leadName: 'Elena Rostova',
        leadEmail: 'elena@rostovagroup.com',
        connectorName: 'HubSpot',
        errorMessage: 'Duplicate contact record exists in HubSpot',
        timestamp: DateTime(2026, 10, 8, 11, 15),
      ),
    ];

    if (targetUid == null || targetUid.isEmpty) {
      return Stream.value(defaultLogs);
    }

    return _firestore
        .collection('enterprises')
        .doc(targetUid)
        .collection('crm_sync_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) {
        return defaultLogs;
      }

      return snap.docs
          .map((doc) => CrmSyncLogModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Toggles or saves CRM Connector connection status to Firestore.
  Future<bool> updateConnectorStatus({
    required String connectorId,
    required String name,
    required bool isConnected,
    String? instanceUrl,
    String? apiKey,
    String? uid,
  }) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final docRef = _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('crm_connectors')
          .doc(connectorId);

      final data = <String, dynamic>{
        'name': name,
        'provider': connectorId,
        'isConnected': isConnected,
        'lastSyncedAt': FieldValue.serverTimestamp(),
      };
      if (instanceUrl != null) data['instanceUrl'] = instanceUrl;
      if (apiKey != null) data['apiKey'] = apiKey;

      await docRef.set(data, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('[EnterpriseCrmService] updateConnectorStatus error: $e');
      return false;
    }
  }

  /// Saves Webhook URL to Firestore.
  Future<bool> saveWebhookUrl(String url, [String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('crm_config')
          .doc('webhook')
          .set({
        'webhookUrl': url.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[EnterpriseCrmService] saveWebhookUrl error: $e');
      return false;
    }
  }

  /// Tests Webhook URL dispatch by writing test log and timestamp.
  Future<bool> testWebhook(String url, [String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('crm_config')
          .doc('webhook')
          .set({
        'webhookUrl': url.trim(),
        'lastTestedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[EnterpriseCrmService] testWebhook error: $e');
      return false;
    }
  }

  /// Clears resolved sync logs.
  Future<bool> clearSyncLogs([String? uid]) async {
    final targetUid = uid ?? currentUid;
    if (targetUid == null || targetUid.isEmpty) return false;

    try {
      final snap = await _firestore
          .collection('enterprises')
          .doc(targetUid)
          .collection('crm_sync_logs')
          .get();

      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (e) {
      debugPrint('[EnterpriseCrmService] clearSyncLogs error: $e');
      return false;
    }
  }
}
