// lib/backend/master_admin/master_admin_global_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'companies/models/master_company_model.dart';

/// Unified Master Admin Global Service
/// Fetches and manages platform-wide data across ALL users without user-level filtering.
class MasterAdminGlobalService {
  MasterAdminGlobalService._internal();
  static final MasterAdminGlobalService instance = MasterAdminGlobalService._internal();

  static const String baseUrl = "https://digitalbusinesscloudcard.com";

  /// ⚡ Fetches ALL companies globally across the entire platform
  static Future<Map<String, dynamic>> fetchGlobalCompanies({
    String filter = "all", // "all" | "active" | "pending" | "suspended"
    String search = "",
  }) async {
    List<MasterCompanyModel> remoteCompanies = [];
    int total = 0;
    int active = 0;
    int suspended = 0;
    int pending = 0;

    // 1. Try Next.js Global Sync API
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final uri = Uri.parse("$baseUrl/api/sync/master-admin-companies").replace(
        queryParameters: {
          "filter": filter,
          if (search.trim().isNotEmpty) "search": search.trim(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true && resData['data'] != null) {
          final data = resData['data'];
          final metrics = data['metrics'] ?? {};
          final List compList = data['companies'] ?? [];

          total = (metrics['total'] as num?)?.toInt() ?? compList.length;
          active = (metrics['active'] as num?)?.toInt() ?? 0;
          suspended = (metrics['suspended'] as num?)?.toInt() ?? 0;
          pending = (metrics['pending'] as num?)?.toInt() ?? 0;

          for (final item in compList) {
            if (item is Map<String, dynamic>) {
              remoteCompanies.add(MasterCompanyModel.fromMap(
                item['id'] ?? item['_id'] ?? '',
                item,
              ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint("[MasterAdminGlobalService] Global API notice: $e");
    }

    // 2. Cross-reference with Firestore `enterprises` and `companies` to ensure 100% coverage
    try {
      final snapEnterprises = await FirebaseFirestore.instance.collection('enterprises').get();
      for (final doc in snapEnterprises.docs) {
        if (!remoteCompanies.any((c) => c.id == doc.id)) {
          final model = MasterCompanyModel.fromMap(doc.id, doc.data());
          remoteCompanies.add(model);
        }
      }

      final snapCompanies = await FirebaseFirestore.instance.collection('companies').get();
      for (final doc in snapCompanies.docs) {
        if (!remoteCompanies.any((c) => c.id == doc.id)) {
          final model = MasterCompanyModel.fromMap(doc.id, doc.data());
          remoteCompanies.add(model);
        }
      }
    } catch (e) {
      debugPrint("[MasterAdminGlobalService] Firestore fallback notice: $e");
    }

    // Recalculate metrics accurately
    total = remoteCompanies.length;
    active = remoteCompanies.where((c) => c.status.toLowerCase() == 'active').length;
    pending = remoteCompanies.where((c) => c.status.toLowerCase() == 'pending').length;
    suspended = remoteCompanies.where((c) => c.status.toLowerCase() == 'suspended').length;

    // Apply local search and filter if specified
    var filtered = remoteCompanies;
    final query = search.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((c) =>
          c.name.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query) ||
          c.plan.toLowerCase().contains(query) ||
          (c.domain != null && c.domain!.toLowerCase().contains(query))).toList();
    }

    if (filter == 'active') {
      filtered = filtered.where((c) => c.status.toLowerCase() == 'active').toList();
    } else if (filter == 'pending') {
      filtered = filtered.where((c) => c.status.toLowerCase() == 'pending').toList();
    } else if (filter == 'suspended') {
      filtered = filtered.where((c) => c.status.toLowerCase() == 'suspended').toList();
    }

    return {
      'success': true,
      'total': total,
      'active': active,
      'pending': pending,
      'suspended': suspended,
      'companies': filtered,
    };
  }

  /// ⚡ Fetches ALL individuals globally across the entire platform
  static Future<Map<String, dynamic>> fetchGlobalIndividuals({
    String filter = "all", // "all" | "active" | "deactivated"
    String search = "",
  }) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      final uri = Uri.parse("$baseUrl/api/sync/master-admin-individuals").replace(
        queryParameters: {
          "filter": filter,
          if (search.trim().isNotEmpty) "search": search.trim(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          final data = resData['data'];
          final metrics = data['metrics'] ?? {};

          return {
            'success': true,
            'total': metrics['total'] ?? 0,
            'active': metrics['active'] ?? 0,
            'deactivated': metrics['deactivated'] ?? 0,
            'individuals': data['individuals'] ?? [],
          };
        }
      }
      return {'success': false, 'error': 'Server returned ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
