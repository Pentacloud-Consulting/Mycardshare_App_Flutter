// ── Root Sync Model ──────────────────────────────────────────────
class IndividualSyncData {
  final IndividualCardProfileModel profile;
  final IndividualAnalyticsModel analytics;
  final List<IndividualLeadModel> leads;
  final List<VaultCardModel> vault;
  final IndividualSettingsModel settings;
  final String syncedAt;

  IndividualSyncData({
    required this.profile,
    required this.analytics,
    required this.leads,
    required this.vault,
    required this.settings,
    required this.syncedAt,
  });

  factory IndividualSyncData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return IndividualSyncData(
      profile: IndividualCardProfileModel.fromJson(data['profile'] ?? {}),
      analytics: IndividualAnalyticsModel.fromJson(data['analytics'] ?? {}),
      leads: (data['leads'] as List? ?? [])
          .map((l) => IndividualLeadModel.fromJson(l))
          .toList(),
      vault: (data['vault'] as List? ?? [])
          .map((v) => VaultCardModel.fromJson(v))
          .toList(),
      settings: IndividualSettingsModel.fromJson(data['settings'] ?? {}),
      syncedAt: data['syncedAt'] ?? '',
    );
  }
}

// ── 1. Digital Business Card Profile (profile/ & home/) ───────────
class IndividualCardProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String jobTitle;
  final String company;
  final String bio;
  final String cardSlug;
  final String? avatarUrl;
  final String? bannerUrl;
  final String themeColor;
  final bool isPublished;
  final Map<String, dynamic> socialLinks;
  final String cardUrl;

  IndividualCardProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.jobTitle,
    required this.company,
    required this.bio,
    required this.cardSlug,
    this.avatarUrl,
    this.bannerUrl,
    required this.themeColor,
    required this.isPublished,
    required this.socialLinks,
    required this.cardUrl,
  });

  factory IndividualCardProfileModel.fromJson(Map<String, dynamic> json) =>
      IndividualCardProfileModel(
        uid: json['uid'] ?? '',
        fullName: json['fullName'] ?? json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        company: json['company'] ?? '',
        bio: json['bio'] ?? '',
        cardSlug: json['cardSlug'] ?? json['slug'] ?? '',
        avatarUrl: json['avatarUrl'] ?? json['photoURL'],
        bannerUrl: json['bannerUrl'],
        themeColor: json['themeColor'] ?? '#0052FF',
        isPublished: json['isPublished'] ?? true,
        socialLinks: json['socialLinks'] as Map<String, dynamic>? ?? {},
        cardUrl: json['cardUrl'] ?? 'https://mycardshare.com/card/${json['cardSlug'] ?? ''}',
      );
}

// ── 2. Analytics Model (analytics/) ────────────────────────────────
class IndividualAnalyticsModel {
  final int totalViews;
  final int uniqueVisitors;
  final int totalShares;
  final int leadsCaptured;
  final Map<String, int> clickBreakdown;

  IndividualAnalyticsModel({
    required this.totalViews,
    required this.uniqueVisitors,
    required this.totalShares,
    required this.leadsCaptured,
    required this.clickBreakdown,
  });

  factory IndividualAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final rawClicks = json['clickBreakdown'];
    final Map<String, int> clicks = {};
    if (rawClicks is Map) {
      rawClicks.forEach((k, v) {
        if (v is num) clicks[k.toString()] = v.toInt();
      });
    }

    return IndividualAnalyticsModel(
      totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
      uniqueVisitors: (json['uniqueVisitors'] as num?)?.toInt() ?? 0,
      totalShares: (json['totalShares'] as num?)?.toInt() ?? 0,
      leadsCaptured: (json['leadsCaptured'] as num?)?.toInt() ?? 0,
      clickBreakdown: clicks,
    );
  }
}

// ── 3. Leads Model (lead/ & leads/) ────────────────────────────────
class IndividualLeadModel {
  final String leadId;
  final String name;
  final String email;
  final String phone;
  final String note;
  final String capturedAt;

  IndividualLeadModel({
    required this.leadId,
    required this.name,
    required this.email,
    required this.phone,
    required this.note,
    required this.capturedAt,
  });

  factory IndividualLeadModel.fromJson(Map<String, dynamic> json) =>
      IndividualLeadModel(
        leadId: json['leadId'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        note: json['note'] ?? '',
        capturedAt: json['capturedAt'] ?? '',
      );
}

// ── 4. Vault Saved Card Model (vault/) ─────────────────────────────
class VaultCardModel {
  final String id;
  final String contactName;
  final String company;
  final String jobTitle;
  final String email;
  final String phone;
  final String? cardSlug;
  final String? avatarUrl;

  VaultCardModel({
    required this.id,
    required this.contactName,
    required this.company,
    required this.jobTitle,
    required this.email,
    required this.phone,
    this.cardSlug,
    this.avatarUrl,
  });

  factory VaultCardModel.fromJson(Map<String, dynamic> json) => VaultCardModel(
        id: json['id'] ?? '',
        contactName: json['contactName'] ?? json['name'] ?? '',
        company: json['company'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        cardSlug: json['cardSlug'],
        avatarUrl: json['avatarUrl'],
      );
}

// ── 5. Settings Model (settings/) ──────────────────────────────────
class IndividualSettingsModel {
  final String plan;
  final bool enableNfc;
  final bool publicDirectoryListing;
  final bool qrCodeLogoEnabled;

  IndividualSettingsModel({
    required this.plan,
    required this.enableNfc,
    required this.publicDirectoryListing,
    required this.qrCodeLogoEnabled,
  });

  factory IndividualSettingsModel.fromJson(Map<String, dynamic> json) =>
      IndividualSettingsModel(
        plan: json['plan'] ?? 'Pro',
        enableNfc: json['enableNfc'] ?? true,
        publicDirectoryListing: json['publicDirectoryListing'] ?? true,
        qrCodeLogoEnabled: json['qrCodeLogoEnabled'] ?? true,
      );
}
