// lib/backend/master_admin/master_individuals_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

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
  static const String primaryUrl = 'https://digitalbusinesscloudcard.com/api/platform/individuals';
  static const String fallbackUrl = 'https://digitalbusinesscloudcard.com/api/sync/master-admin-individuals';
  static const String baseUrl = primaryUrl;

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
      Uri.parse(primaryUrl).replace(queryParameters: queryParams),
      Uri.parse(fallbackUrl).replace(queryParameters: queryParams),
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
            return MasterIndividualsResponse.fromJson(decoded);
          }
        }
      } catch (e) {
        debugPrint('[MasterIndividualsService] Endpoint $uri error: $e');
      }
    }

    throw Exception('Failed to load individuals from server (Status: ${lastResponse?.statusCode ?? "no response"})');
  }

  /// Master Admin Permanent Delete Action
  static Future<bool> confirmDeleteIndividual({
    String? token,
    required String userId,
  }) async {
    final actualToken = token ?? await getAuthToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        if (actualToken.isNotEmpty) 'Authorization': 'Bearer $actualToken',
      },
      body: json.encode({
        'action': 'confirm_delete',
        'userId': userId,
      }),
    );

    final decoded = json.decode(response.body);
    return response.statusCode == 200 && decoded['success'] == true;
  }
}
