import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../individual/profile/individual_profile_store.dart';
import '../../core/utils/image_url_formatter.dart';
import 'banner fetch/banner fetch.dart';
import 'home/employee_home_backend.dart';

/// Central Dual-Database Sync Service for Employee Profile and Corporate Card
/// Seamlessly synchronizes across Firestore and Next.js /api/sync/employee endpoint.
class EmployeeSyncService extends ChangeNotifier {
  EmployeeSyncService._internal();
  static final EmployeeSyncService instance = EmployeeSyncService._internal();

  static const List<String> _hosts = [
    'https://mycardshare.com',
    'https://digitalbusinesscloudcard.com',
  ];

  Map<String, dynamic>? _syncedCompanyData;
  Map<String, dynamic>? _syncedCardData;
  bool _isLoading = false;

  Map<String, dynamic>? get syncedCompanyData => _syncedCompanyData;
  Map<String, dynamic>? get syncedCardData => _syncedCardData;
  bool get isLoading => _isLoading;

  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      debugPrint('[EmployeeSyncService] Auth token note: $e');
    }

    return headers;
  }

  /// Fetches employee card & company brand settings from Next.js /api/sync/employee
  Future<Map<String, dynamic>?> fetchEmployeeSyncData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final headers = await _headers();

      for (final host in _hosts) {
        for (final endpoint in ['/api/sync/employee', '/app-sync/employee']) {
          try {
            final uri = Uri.parse('$host$endpoint');
            final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));

            if (res.statusCode >= 200 && res.statusCode < 300) {
              final json = jsonDecode(res.body);
              final data = json['data'] is Map<String, dynamic> ? json['data'] : json;

              if (data != null && data is Map<String, dynamic>) {
                final company = data['company'] is Map<String, dynamic> ? data['company'] as Map<String, dynamic> : null;
                final card = data['card'] is Map<String, dynamic> ? data['card'] as Map<String, dynamic> : null;

                if (company != null) {
                  _syncedCompanyData = company;
                }
                if (card != null) {
                  _syncedCardData = card;
                }

                // 1. Immediately hydrate IndividualProfileStore
                if (card != null) {
                  IndividualProfileStore.instance.updateProfileFromSync(
                    cardData: card,
                    companyData: company,
                  );
                }

                // 2. Immediately hydrate EmployeeHomeBackendService
                final fullName = (card?['fullName'] ?? card?['name'])?.toString().trim();
                final role = (card?['jobTitle'] ?? card?['title'])?.toString().trim();
                final compName = (company?['companyName'] ?? card?['companyName'])?.toString().trim();
                final rawAvatar = (card?['avatarUrl'] ?? card?['avatar'])?.toString().trim();
                final avatar = ImageUrlFormatter.format(rawAvatar);

                EmployeeHomeBackendService.instance.updateHomeProfile(
                  userName: (fullName != null && fullName.isNotEmpty && fullName != 'User') ? fullName : null,
                  role: (role != null && role.isNotEmpty && role != 'Member') ? role : null,
                  companyName: (compName != null && compName.isNotEmpty && compName != 'Enterprise Workspace') ? compName : null,
                  avatarUrl: avatar,
                );

                // 3. Immediately hydrate EmployeeBannerFetchService
                final rawLogo = (company?['companyLogo'] ?? card?['companyLogo'])?.toString().trim();
                final rawBanner = (company?['companyBanner'] ?? card?['bannerUrl'])?.toString().trim();
                EmployeeBannerFetchService.instance.updateBrandFromSync(
                  companyName: compName,
                  logoUrl: ImageUrlFormatter.format(rawLogo),
                  bannerUrl: ImageUrlFormatter.format(rawBanner),
                  brandColor: company?['brandColor']?.toString(),
                );

                // 4. Cache to SharedPreferences for instant reload
                try {
                  final prefs = await SharedPreferences.getInstance();
                  if (fullName != null && fullName.isNotEmpty) await prefs.setString('emp_cached_name', fullName);
                  if (role != null && role.isNotEmpty) await prefs.setString('emp_cached_role', role);
                  if (compName != null && compName.isNotEmpty) await prefs.setString('emp_cached_company', compName);
                  if (avatar != null && avatar.isNotEmpty) await prefs.setString('emp_cached_avatar', avatar);
                } catch (_) {}

                notifyListeners();
                return data;
              }
            }
          } catch (e) {
            debugPrint('[EmployeeSyncService] GET $endpoint on $host error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[EmployeeSyncService] fetchEmployeeSyncData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Pushes employee card updates to Next.js backend while respecting enterprise brand policies
  Future<bool> saveEmployeeCardToApi(Map<String, dynamic> cardPayload) async {
    try {
      final headers = await _headers();
      final body = jsonEncode(cardPayload);

      for (final host in _hosts) {
        for (final endpoint in ['/api/sync/employee', '/app-sync/employee']) {
          try {
            final uri = Uri.parse('$host$endpoint');
            final res = await http
                .patch(uri, headers: headers, body: body)
                .timeout(const Duration(seconds: 8));

            if (res.statusCode >= 200 && res.statusCode < 300) {
              debugPrint('[EmployeeSyncService] PATCH $endpoint on $host success');
              return true;
            }
          } catch (e) {
            debugPrint('[EmployeeSyncService] PATCH $endpoint on $host error: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('[EmployeeSyncService] saveEmployeeCardToApi error: $e');
    }
    return false;
  }
}
