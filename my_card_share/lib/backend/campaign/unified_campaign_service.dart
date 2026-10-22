import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnifiedCampaignService {
  static const String baseUrl = "https://mycardshare.com";
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = user != null ? await user.getIdToken() : "";
    return {
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// 1. FETCH CAMPAIGNS (Role-Aware: Enterprise vs Individual)
  static Future<Map<String, dynamic>> fetchCampaigns({
    required bool isEnterprise,
    String status = "all", // "all" | "active" | "ended"
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "";

    Map<String, dynamic> apiResult = {};
    try {
      final headers = await _getHeaders();
      final endpoint = isEnterprise ? "enterprise-campaigns" : "individual-campaigns";
      final res = await http.get(
        Uri.parse("$baseUrl/api/sync/$endpoint?status=$status"),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json["data"] is Map<String, dynamic>) {
          apiResult = json["data"];
        }
      }
    } catch (e) {
      debugPrint("[UnifiedCampaignService] Fetch error from API: $e");
    }

    // Load / merge with Firestore campaigns
    List<Map<String, dynamic>> firestoreCampaigns = [];
    if (uid.isNotEmpty) {
      try {
        final collectionPath = isEnterprise ? "enterprises" : "users";
        final snap = await _firestore
            .collection(collectionPath)
            .doc(uid)
            .collection("campaigns")
            .orderBy("createdAt", descending: true)
            .get();

        for (final doc in snap.docs) {
          final data = doc.data();
          final campStatus = data["status"] ?? "Active";
          if (status == "active" && campStatus.toString().toLowerCase() != "active") continue;
          if (status == "ended" && campStatus.toString().toLowerCase() != "ended") continue;

          firestoreCampaigns.add({
            "id": doc.id,
            "title": data["name"] ?? data["title"] ?? "Marketing Campaign",
            "tag": "CAMPAIGN",
            "color": _getColorForIndex(firestoreCampaigns.length),
            "scans": data["scans"] ?? 0,
            "conv": data["conversionRate"] ?? "0%",
            "endsCaption": data["endsCaption"] ?? "Ends in ${data["durationDays"] ?? 14} days",
            "status": campStatus,
            "targetUrl": data["targetUrl"] ?? "",
            "qrCodeUrl": data["qrCodeUrl"] ?? "",
            "createdAt": data["createdAt"],
          });
        }
      } catch (fsErr) {
        debugPrint("[UnifiedCampaignService] Firestore read error: $fsErr");
      }
    }

    // Combine list
    final List<dynamic> apiCampaigns = apiResult["campaigns"] is List ? apiResult["campaigns"] : [];
    final combinedMap = <String, Map<String, dynamic>>{};

    // Add Firestore campaigns first
    for (final c in firestoreCampaigns) {
      combinedMap[c["id"].toString()] = c;
    }
    // Add API campaigns
    for (final c in apiCampaigns) {
      if (c is Map<String, dynamic>) {
        final id = (c["id"] ?? c["_id"] ?? "").toString();
        if (id.isNotEmpty) {
          combinedMap[id] = {
            "id": id,
            "title": c["name"] ?? c["title"] ?? "Campaign",
            "tag": "CAMPAIGN",
            "color": _getColorForIndex(combinedMap.length),
            "scans": c["scans"] ?? c["scansCount"] ?? 0,
            "conv": c["conversionRate"] ?? c["conv"] ?? "0%",
            "endsCaption": c["endsCaption"] ?? "Ends in ${c["durationDays"] ?? 14} days",
            "status": c["status"] ?? "Active",
            "targetUrl": c["targetUrl"] ?? "",
            "qrCodeUrl": c["qrCodeUrl"] ?? "",
          };
        }
      }
    }

    final finalCampaigns = combinedMap.values.toList();
    final activeCount = finalCampaigns.where((c) => c["status"] == "Active").length;
    int totalScans = 0;
    for (final c in finalCampaigns) {
      if (c["scans"] is num) {
        totalScans += (c["scans"] as num).toInt();
      }
    }

    return {
      "summary": {
        "activeCampaignsCount": activeCount > 0 ? activeCount : (apiResult["summary"]?["activeCampaignsCount"] ?? 0),
        "totalScansThisMonth": totalScans > 0 ? totalScans.toString() : (apiResult["summary"]?["totalScansThisMonth"]?.toString() ?? "0"),
      },
      "campaigns": finalCampaigns,
    };
  }

  /// 2. CREATE NEW CAMPAIGN ("+ New Campaign" Tile Click)
  static Future<Map<String, dynamic>> createCampaign({
    required bool isEnterprise,
    required String name,
    String? description,
    int durationDays = 14,
    double? budget,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "";

    if (name.trim().isEmpty) {
      return {"success": false, "error": "Campaign name cannot be empty."};
    }

    try {
      final collectionPath = isEnterprise ? "enterprises" : "users";
      DocumentReference? docRef;

      // 1. Write to Firestore immediately
      if (uid.isNotEmpty) {
        docRef = _firestore
            .collection(collectionPath)
            .doc(uid)
            .collection("campaigns")
            .doc();

        final trackingUrl = "https://mycardshare.com/c/${docRef.id}";
        final qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(trackingUrl)}";

        await docRef.set({
          "id": docRef.id,
          "name": name.trim(),
          "description": description ?? "",
          "durationDays": durationDays,
          "budget": budget,
          "status": "Active",
          "scans": 0,
          "conversionRate": "0%",
          "targetUrl": trackingUrl,
          "qrCodeUrl": qrCodeUrl,
          "endsCaption": "Ends in $durationDays days",
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }

      // 2. Dispatch to Backend API
      Map<String, dynamic>? apiCampaign;
      try {
        final headers = await _getHeaders();
        final endpoint = isEnterprise ? "enterprise-campaigns" : "individual-campaigns";
        final res = await http.post(
          Uri.parse("$baseUrl/api/sync/$endpoint"),
          headers: headers,
          body: jsonEncode({
            "action": "create",
            "name": name.trim(),
            "description": description ?? "",
            "durationDays": durationDays,
            "budget": ?budget,
            "campaignId": ?docRef?.id,
          }),
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode == 200) {
          final json = jsonDecode(res.body);
          apiCampaign = json["data"]?["campaign"];
        }
      } catch (err) {
        debugPrint("[UnifiedCampaignService] Backend sync note: $err");
      }

      return {
        "success": true,
        "campaign": apiCampaign ?? {
          "id": docRef?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          "title": name.trim(),
          "status": "Active",
          "scans": 0,
          "conv": "0%",
          "endsCaption": "Ends in $durationDays days",
        },
      };
    } catch (e) {
      debugPrint("[UnifiedCampaignService] Create campaign error: $e");
      return {"success": false, "error": e.toString()};
    }
  }

  static dynamic _getColorForIndex(int idx) {
    const colors = [
      0xFF0052FF, // Blue
      0xFF7C3AED, // Purple
      0xFFEC4899, // Pink
      0xFF10B981, // Emerald
      0xFFF59E0B, // Amber
    ];
    return colors[idx % colors.length];
  }
}
