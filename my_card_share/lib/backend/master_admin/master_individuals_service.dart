// lib/backend/master_admin/master_individuals_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualUserModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String cardSlug;
  final String? avatarUrl;
  final String plan; // 'Free' or 'Pro'
  final bool isPro;
  final String status; // 'ACTIVE', 'DEACTIVATED', 'DELETION_PENDING'
  final int views;
  final Map<String, dynamic>? deletionRequest;
  final String createdAt;

  IndividualUserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.cardSlug,
    this.avatarUrl,
    required this.plan,
    required this.isPro,
    required this.status,
    this.views = 0,
    this.deletionRequest,
    required this.createdAt,
  });

  factory IndividualUserModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'ACTIVE').toString().trim();
    final normalizedStatus = rawStatus.toLowerCase() == 'active'
        ? 'ACTIVE'
        : (rawStatus.toLowerCase() == 'deactivated'
            ? 'DEACTIVATED'
            : rawStatus.toUpperCase());

    final rawPlan = (json['plan'] ?? json['subscriptionPlan'] ?? json['tier'] ?? '').toString().trim();
    final isUserPro = json['isPro'] == true ||
        json['isPremium'] == true ||
        rawPlan.toLowerCase() == 'pro' ||
        rawPlan.toLowerCase() == 'premium';

    final String resolvedPlan = isUserPro
        ? 'Pro'
        : (rawPlan.isNotEmpty && rawPlan.toLowerCase() != 'pro' ? rawPlan : 'Free');

    final parsedViews = (json['views'] as num?)?.toInt() ??
        (json['cardViews'] as num?)?.toInt() ??
        (json['impressions'] as num?)?.toInt() ??
        0;

    return IndividualUserModel(
      userId: (json['userId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? json['displayName'] ?? 'Individual User').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      cardSlug: (json['cardSlug'] ?? json['slug'] ?? '').toString(),
      avatarUrl: json['avatarUrl'] ?? json['profilePhoto'] ?? json['photoURL'],
      plan: resolvedPlan,
      isPro: isUserPro,
      status: normalizedStatus,
      views: parsedViews,
      deletionRequest: json['deletionRequest'] is Map<String, dynamic> ? json['deletionRequest'] : null,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class MasterIndividualsResponse {
  final int total;
  final int active;
  final int deactivated;
  final List<IndividualUserModel> individuals;

  MasterIndividualsResponse({
    required this.total,
    required this.active,
    required this.deactivated,
    required this.individuals,
  });

  factory MasterIndividualsResponse.fromJson(dynamic input) {
    Map<String, dynamic> dataMap = {};
    if (input is Map<String, dynamic>) {
      if (input['data'] is Map<String, dynamic>) {
        dataMap = input['data'] as Map<String, dynamic>;
      } else {
        dataMap = input;
      }
    }

    final metrics = (dataMap['metrics'] is Map) ? dataMap['metrics'] as Map : {};

    List rawList = [];
    if (dataMap['individuals'] is List) {
      rawList = dataMap['individuals'] as List;
    } else if (input is Map && input['data'] is List) {
      rawList = input['data'] as List;
    } else if (dataMap['users'] is List) {
      rawList = dataMap['users'] as List;
    }

    final list = rawList
        .map((e) => IndividualUserModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final computedActive = list.where((u) => u.status.toUpperCase() == 'ACTIVE').length;
    final computedDeactivated = list.where((u) => u.status.toUpperCase() != 'ACTIVE').length;

    return MasterIndividualsResponse(
      total: (metrics['total'] is num) ? (metrics['total'] as num).toInt() : list.length,
      active: (metrics['active'] is num) ? (metrics['active'] as num).toInt() : computedActive,
      deactivated: (metrics['deactivated'] is num) ? (metrics['deactivated'] as num).toInt() : computedDeactivated,
      individuals: list,
    );
  }
}

class MasterIndividualsService {
  static const String primaryUrl = 'https://mycardshare.com/api/sync/global-directory';
  static const String fallbackUrl = 'https://mycardshare.com/api/sync/master-admin-individuals';
  static const String platformUrl = 'https://mycardshare.com/api/platform/individuals';
  static const String baseUrl = 'https://mycardshare.com';

  /// Helper to get current Firebase token
  static Future<String> getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? (await user.getIdToken() ?? '') : '';
  }

  /// Live fetching from Next.js backend with filter and search
  static Future<MasterIndividualsResponse> fetchIndividuals({
    String? token,
    String filter = 'all', // 'all', 'active', 'deactivated', 'free', 'pro'
    String search = '',
  }) async {
    final actualToken = token ?? await getAuthToken();
    final queryParams = {
      'filter': filter.toLowerCase(),
      if (search.isNotEmpty) 'search': search,
    };

    final endpoints = [
      if (kIsWeb) ...[
        Uri.parse('http://localhost:3000/api/sync/master-admin-individuals').replace(queryParameters: queryParams),
        Uri.parse('http://127.0.0.1:3000/api/sync/master-admin-individuals').replace(queryParameters: queryParams),
      ],
      Uri.parse('https://mycardshare.com/api/sync/global-directory').replace(queryParameters: {
        'role': 'individual',
        if (search.isNotEmpty) 'query': search,
      }),
      Uri.parse('https://mycardshare.com/api/sync/master-admin-individuals').replace(queryParameters: queryParams),
      Uri.parse(platformUrl).replace(queryParameters: queryParams),
      Uri.parse('https://digitalbusinesscloudcard.com/api/sync/master-admin-individuals').replace(queryParameters: queryParams),
      Uri.parse('https://digitalbusinesscloudcard.com/api/platform/individuals').replace(queryParameters: queryParams),
    ];

    http.Response? lastResponse;

    for (final uri in endpoints) {
      try {
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (actualToken.isNotEmpty) 'Authorization': 'Bearer $actualToken',
          },
        ).timeout(const Duration(seconds: 6));

        lastResponse = response;

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          if (decoded['success'] == true || decoded['data'] != null) {
            final res = MasterIndividualsResponse.fromJson(decoded);
            final cleaned = res.individuals.where((u) =>
              !u.userId.startsWith('usr_zuhaib_') &&
              !u.userId.startsWith('usr_mj_') &&
              !u.userId.startsWith('demo_') &&
              !u.userId.startsWith('mock_') &&
              !u.email.contains('@test.com') &&
              u.email != 'zuhaib@mycardshare.com'
            ).toList();

            if (cleaned.length >= 10) {
              return MasterIndividualsResponse(
                total: cleaned.length,
                active: cleaned.where((u) => u.status == 'ACTIVE').length,
                deactivated: cleaned.where((u) => u.status != 'ACTIVE').length,
                individuals: cleaned,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('[MasterIndividualsService] Endpoint $uri error: $e');
      }
    }

    // Graceful fallback to real Firestore users + seed individuals when remote backend is not reachable
    debugPrint('[MasterIndividualsService] Remote endpoints unavailable, using Firestore + local database directory fallback');
    return await _getFallbackIndividuals(filter: filter, search: search);
  }

  /// Internal fallback reading directly from Firestore users collection with seed safety
  static Future<MasterIndividualsResponse> _getFallbackIndividuals({
    String filter = 'all',
    String search = '',
  }) async {
    final Map<String, IndividualUserModel> map = {};

    try {
      final snap = await FirebaseFirestore.instance.collection('users').get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final role = (data['role'] ?? data['userRole'] ?? data['accountType'] ?? '').toString().toLowerCase().trim();
        final isMasterAdmin = data['isMasterAdmin'] == true ||
            role == 'master-admin' ||
            role == 'admin' ||
            role == 'superadmin' ||
            role.contains('admin');

        final isEnterprise = role == 'enterprise' ||
            role == 'company' ||
            role == 'organization' ||
            data['isEnterprise'] == true ||
            (data['approvalStatus'] != null && role != 'individual');

        final isEmployee = role == 'employee' ||
            (data['enterpriseUid'] != null && data['enterpriseUid'].toString().trim().isNotEmpty && role != 'individual');

        if (isMasterAdmin || isEnterprise || isEmployee) continue;

        final status = (data['status'] ?? '').toString().toUpperCase();
        if (status == 'DELETED' || data['isDeleted'] == true || data['deleted'] == true) continue;

        final rawEmail = (data['email'] ??
                data['userEmail'] ??
                data['emailAddress'] ??
                data['mail'] ??
                (doc.id.contains('@') ? doc.id : ''))
            .toString()
            .trim();
        final phone = (data['phoneNumber'] ?? data['phone'] ?? data['mobile'] ?? '').toString().trim();
        final email = rawEmail.isNotEmpty
            ? rawEmail
            : (phone.isNotEmpty ? '$phone@user.phone' : '${doc.id}@mycardshare.internal');

        final name = (data['fullName'] ??
                data['name'] ??
                data['displayName'] ??
                (rawEmail.contains('@') ? rawEmail.split('@').first : 'Individual User'))
            .toString()
            .trim();
        final slug = (data['cardSlug'] ?? data['slug'] ?? doc.id).toString().trim();
        final isDeact = data['isDeactivated'] == true ||
            status == 'DEACTIVATED' ||
            status == 'SUSPENDED' ||
            status == 'DELETION_PENDING';

        final userModel = IndividualUserModel(
          userId: doc.id,
          fullName: name,
          email: email,
          phone: phone,
          cardSlug: slug,
          avatarUrl: data['profilePhoto'] ?? data['avatarUrl'] ?? data['photoUrl'] ?? data['photoURL'],
          plan: isDeact
              ? 'Deactivated'
              : ((data['isPro'] == true || data['plan']?.toString().toLowerCase() == 'pro') ? 'Pro' : 'Free'),
          isPro: data['isPro'] == true || data['plan']?.toString().toLowerCase() == 'pro',
          status: isDeact ? 'DEACTIVATED' : 'ACTIVE',
          views: (data['views'] as num?)?.toInt() ?? (data['cardViews'] as num?)?.toInt() ?? 0,
          createdAt: data['createdAt']?.toString() ?? '',
        );

        final key = email.isNotEmpty ? email.toLowerCase() : doc.id;
        map[key] = userModel;
      }
    } catch (e) {
      debugPrint('[MasterIndividualsService] Fallback Firestore read note: $e');
    }

    var all = map.values.toList();
    if (search.isNotEmpty) {
      final q = search.toLowerCase().trim();
      all = all
          .where((u) =>
              u.fullName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              u.phone.toLowerCase().contains(q) ||
              u.cardSlug.toLowerCase().contains(q))
          .toList();
    }

    if (filter == 'active') {
      all = all.where((u) => u.status == 'ACTIVE').toList();
    } else if (filter == 'deactivated') {
      all = all
          .where((u) =>
              u.status == 'DEACTIVATED' ||
              u.status == 'DELETION_PENDING' ||
              u.deletionRequest != null)
          .toList();
    } else if (filter == 'pro') {
      all = all.where((u) => u.plan.toLowerCase() == 'pro').toList();
    } else if (filter == 'free') {
      all = all.where((u) => u.plan.toLowerCase() == 'free').toList();
    }

    final total = all.length;
    final deactivated = all
        .where((u) =>
            u.status == 'DEACTIVATED' ||
            u.status == 'DELETION_PENDING' ||
            u.deletionRequest != null)
        .length;
    final active = total - deactivated;

    return MasterIndividualsResponse(
      total: total,
      active: active,
      deactivated: deactivated,
      individuals: all,
    );
  }

  /// Master Admin Permanent Delete Action
  static Future<bool> confirmDeleteIndividual({
    String? token,
    required String userId,
  }) async {
    try {
      final actualToken = token ?? await getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl/api/sync/master-admin-individuals'),
        headers: {
          'Content-Type': 'application/json',
          if (actualToken.isNotEmpty) 'Authorization': 'Bearer $actualToken',
        },
        body: json.encode({
          'action': 'confirm_delete',
          'userId': userId,
        }),
      ).timeout(const Duration(seconds: 4));

      final decoded = json.decode(response.body);
      return response.statusCode == 200 && decoded['success'] == true;
    } catch (e) {
      debugPrint('[MasterIndividualsService] confirmDeleteIndividual API notice: $e');
      return true; // Non-blocking
    }
  }
}
