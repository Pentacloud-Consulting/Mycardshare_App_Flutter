class MasterAdminEndpoints {
  MasterAdminEndpoints._();

  static const String baseUrl = 'https://mycardshare.com';

  // Platform Dashboard & Sync
  static const String masterAdminSync = '/api/sync/master-admin';
  static const String platformDashboard = '/api/platform/dashboard';
  static const String platformStats = '/api/platform/stats';
  static const String platformAnalytics = '/api/platform/analytics';

  // Companies Management
  static const String companies = '/api/platform/companies';
  static String companyDetail(String id) => '/api/platform/companies/$id';
  static String companyApproval(String id) => '/api/platform/companies/$id/approval';
  static String companySuspend(String id) => '/api/platform/companies/$id/suspend';

  // Individuals Directory
  static const String individuals = '/api/platform/individuals';
  static String individualDetail(String id) => '/api/platform/individuals/$id';

  // Leads & Workspaces
  static const String platformLeads = '/api/platform/leads';
  static const String platformWorkspaces = '/api/platform/workspaces';
  static const String platformCampaigns = '/api/platform/campaigns';

  // Settings & System Health
  static const String superAdmins = '/api/platform/super-admins';
  static const String healthCheck = '/api/platform/health';
}
