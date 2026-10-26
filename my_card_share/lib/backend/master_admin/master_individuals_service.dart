// lib/backend/master_admin/master_individuals_service.dart
import 'dart:convert';
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
    this.deletionRequest,
    required this.createdAt,
  });

  factory IndividualUserModel.fromJson(Map<String, dynamic> json) {
    return IndividualUserModel(
      userId: json['userId'] ?? json['id'] ?? json['_id'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? 'Individual User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      cardSlug: json['cardSlug'] ?? json['slug'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['profilePhoto'],
      plan: json['plan'] ?? 'Free',
      isPro: json['isPro'] ?? false,
      status: json['status'] ?? 'ACTIVE',
      deletionRequest: json['deletionRequest'],
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

  factory MasterIndividualsResponse.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] ?? {};
    final list = (json['individuals'] as List? ?? [])
        .map((e) => IndividualUserModel.fromJson(e))
        .toList();
    return MasterIndividualsResponse(
      total: metrics['total'] ?? list.length,
      active: metrics['active'] ?? list.where((u) => u.status == 'ACTIVE').length,
      deactivated: metrics['deactivated'] ?? list.where((u) => u.status != 'ACTIVE').length,
      individuals: list,
    );
  }
}

class MasterIndividualsService {
  static const String baseUrl = 'https://digitalbusinesscloudcard.com/api/sync/master-admin-individuals';

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
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (actualToken.isNotEmpty) 'Authorization': 'Bearer $actualToken',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        return MasterIndividualsResponse.fromJson(decoded['data']);
      }
    }
    throw Exception('Failed to load individuals from server (Status: ${response.statusCode})');
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
