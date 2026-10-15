// ── Unified Enterprise Data Model (enterprise_sync_model.dart) ────────────────

class EnterpriseSyncData {
  final BrandProfileModel brandProfile;
  final DashboardMetricsModel dashboardMetrics;
  final WorkspaceDataModel workspace;
  final LeadsDataModel leadsData;
  final List<dynamic> campaigns;
  final SettingsDataModel settings;
  final String syncedAt;

  EnterpriseSyncData({
    required this.brandProfile,
    required this.dashboardMetrics,
    required this.workspace,
    required this.leadsData,
    required this.campaigns,
    required this.settings,
    required this.syncedAt,
  });

  factory EnterpriseSyncData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return EnterpriseSyncData(
      brandProfile: BrandProfileModel.fromJson(data['brandProfile'] ?? {}),
      dashboardMetrics: DashboardMetricsModel.fromJson(data['dashboardMetrics'] ?? {}),
      workspace: WorkspaceDataModel.fromJson(data['workspace'] ?? {}),
      leadsData: LeadsDataModel.fromJson(data['leadsData'] ?? {}),
      campaigns: data['campaigns'] as List? ?? [],
      settings: SettingsDataModel.fromJson(data['settings'] ?? {}),
      syncedAt: data['syncedAt'] ?? '',
    );
  }
}

// ── 1. Brand Profile Model (brand_profile/) ────────────────────────
class BrandProfileModel {
  final String companyId;
  final String companyName;
  final String slug;
  final String? companyLogo;
  final String? companyBanner;
  final String brandColor;
  final bool isColorLocked;
  final String website;
  final String officialEmail;
  final String phone;
  final String address;
  final String industry;
  final List<dynamic> socialLinks;
  final String verifiedDomain;

  BrandProfileModel({
    required this.companyId,
    required this.companyName,
    required this.slug,
    this.companyLogo,
    this.companyBanner,
    required this.brandColor,
    required this.isColorLocked,
    required this.website,
    required this.officialEmail,
    required this.phone,
    required this.address,
    required this.industry,
    required this.socialLinks,
    required this.verifiedDomain,
  });

  factory BrandProfileModel.fromJson(Map<String, dynamic> json) => BrandProfileModel(
        companyId: json['companyId'] ?? '',
        companyName: json['companyName'] ?? '',
        slug: json['slug'] ?? '',
        companyLogo: json['companyLogo'],
        companyBanner: json['companyBanner'],
        brandColor: json['brandColor'] ?? '#0052FF',
        isColorLocked: json['isColorLocked'] ?? false,
        website: json['website'] ?? '',
        officialEmail: json['officialEmail'] ?? '',
        phone: json['phone'] ?? '',
        address: json['address'] ?? '',
        industry: json['industry'] ?? '',
        socialLinks: json['socialLinks'] as List? ?? [],
        verifiedDomain: json['verifiedDomain'] ?? '',
      );
}

// ── 2. Dashboard Metrics (home_backend/) ──────────────────────────
class DashboardMetricsModel {
  final int totalEmployees;
  final int activeEmployees;
  final int totalLeads;
  final int totalCardViews;
  final int totalCardShares;
  final double ctrPercentage;
  final int pendingRequestsCount;
  final double monthlyGrowthRate;

  DashboardMetricsModel({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.totalLeads,
    required this.totalCardViews,
    required this.totalCardShares,
    required this.ctrPercentage,
    required this.pendingRequestsCount,
    required this.monthlyGrowthRate,
  });

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) => DashboardMetricsModel(
        totalEmployees: json['totalEmployees'] ?? 0,
        activeEmployees: json['activeEmployees'] ?? 0,
        totalLeads: json['totalLeads'] ?? 0,
        totalCardViews: json['totalCardViews'] ?? 0,
        totalCardShares: json['totalCardShares'] ?? 0,
        ctrPercentage: (json['ctrPercentage'] is num)
            ? (json['ctrPercentage'] as num).toDouble()
            : 0.0,
        pendingRequestsCount: json['pendingRequestsCount'] ?? 0,
        monthlyGrowthRate: (json['monthlyGrowthRate'] is num)
            ? (json['monthlyGrowthRate'] as num).toDouble()
            : 0.0,
      );
}

// ── 3. Workspace Data & Join Requests (workspace/ & request/) ───────
class WorkspaceDataModel {
  final List<EmployeeItemModel> employees;
  final List<JoinRequestItemModel> joinRequests;
  final SeatAllocationModel seatAllocation;

  WorkspaceDataModel({
    required this.employees,
    required this.joinRequests,
    required this.seatAllocation,
  });

  factory WorkspaceDataModel.fromJson(Map<String, dynamic> json) => WorkspaceDataModel(
        employees: (json['employees'] as List? ?? [])
            .map((e) => EmployeeItemModel.fromJson(e))
            .toList(),
        joinRequests: (json['joinRequests'] as List? ?? [])
            .map((r) => JoinRequestItemModel.fromJson(r))
            .toList(),
        seatAllocation: SeatAllocationModel.fromJson(json['seatAllocation'] ?? {}),
      );
}

class EmployeeItemModel {
  final String userId;
  final String fullName;
  final String workEmail;
  final String jobTitle;
  final String? avatarUrl;
  final String cardSlug;
  final String status;
  final String cardStatus;

  EmployeeItemModel({
    required this.userId,
    required this.fullName,
    required this.workEmail,
    required this.jobTitle,
    this.avatarUrl,
    required this.cardSlug,
    required this.status,
    required this.cardStatus,
  });

  factory EmployeeItemModel.fromJson(Map<String, dynamic> json) => EmployeeItemModel(
        userId: json['userId'] ?? '',
        fullName: json['fullName'] ?? 'Team Member',
        workEmail: json['workEmail'] ?? json['email'] ?? '',
        jobTitle: json['jobTitle'] ?? '',
        avatarUrl: json['avatarUrl'],
        cardSlug: json['cardSlug'] ?? '',
        status: json['status'] ?? 'active',
        cardStatus: json['cardStatus'] ?? 'Published',
      );
}

class JoinRequestItemModel {
  final String requestId;
  final String userId;
  final String userName;
  final String userEmail;
  final String requestedAt;

  JoinRequestItemModel({
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.requestedAt,
  });

  factory JoinRequestItemModel.fromJson(Map<String, dynamic> json) => JoinRequestItemModel(
        requestId: json['requestId'] ?? '',
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? json['fullName'] ?? 'Applicant',
        userEmail: json['userEmail'] ?? json['email'] ?? '',
        requestedAt: json['requestedAt'] ?? '',
      );
}

class SeatAllocationModel {
  final int employeeLimit;
  final int occupiedSeats;
  final int availableSeats;
  final bool isSeatExceeded;

  SeatAllocationModel({
    required this.employeeLimit,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.isSeatExceeded,
  });

  factory SeatAllocationModel.fromJson(Map<String, dynamic> json) => SeatAllocationModel(
        employeeLimit: json['employeeLimit'] ?? 50,
        occupiedSeats: json['occupiedSeats'] ?? 0,
        availableSeats: json['availableSeats'] ?? 0,
        isSeatExceeded: json['isSeatExceeded'] ?? false,
      );
}

// ── 4. Leads & CRM Connectors (enployee_leads/ & connectors/) ──────
class LeadsDataModel {
  final int totalLeads;
  final List<dynamic> recentLeads;
  final Map<String, dynamic> crmConnectors;

  LeadsDataModel({
    required this.totalLeads,
    required this.recentLeads,
    required this.crmConnectors,
  });

  factory LeadsDataModel.fromJson(Map<String, dynamic> json) => LeadsDataModel(
        totalLeads: json['totalLeads'] ?? 0,
        recentLeads: json['recentLeads'] as List? ?? [],
        crmConnectors: json['crmConnectors'] as Map<String, dynamic>? ?? {},
      );
}

// ── 5. Settings (settings/) ───────────────────────────────────────
class SettingsDataModel {
  final String subscriptionPlan;
  final String status;
  final dynamic subscriptionStartDate;
  final dynamic subscriptionEndDate;
  final bool autoApproveDomainMatch;
  final String inviteCode;

  SettingsDataModel({
    required this.subscriptionPlan,
    required this.status,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.autoApproveDomainMatch,
    required this.inviteCode,
  });

  factory SettingsDataModel.fromJson(Map<String, dynamic> json) => SettingsDataModel(
        subscriptionPlan: json['subscriptionPlan'] ?? 'enterprise_pro',
        status: json['status'] ?? 'active',
        subscriptionStartDate: json['subscriptionStartDate'],
        subscriptionEndDate: json['subscriptionEndDate'],
        autoApproveDomainMatch: json['autoApproveDomainMatch'] ?? false,
        inviteCode: json['inviteCode'] ?? '',
      );
}
