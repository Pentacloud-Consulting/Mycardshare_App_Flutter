import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

// Public Web & Landing Imports
import '../../features/public/landing/screen.dart';
import '../../features/public/about/screen.dart';
import '../../features/public/features/screen.dart';
import '../../features/public/pricing/screen.dart';
import '../../features/public/contact/screen.dart';
import '../../features/public/blog/screen.dart';
import '../../features/public/blog_detail/screen.dart';
import '../../features/public/privacy/screen.dart';
import '../../features/public/terms/screen.dart';
import '../../features/public/enterprise_info/screen.dart';

// Auth Imports
import '../../features/auth/login/login.dart';
import '../../features/auth/signup/signup.dart';
import '../../features/auth/join_workspace/join_workspace.dart';
import '../../features/auth/onboarding/onboarding.dart';
import '../../features/auth/reset_password/reset_password.dart';

// Public Card Import
import '../../features/public_card/card.dart';

// Individual / Portal Imports
import '../../features/individual/portal_home/portal.dart';
import '../../features/individual/profile_editor/profile.dart';
import '../../features/individual/vault/vault.dart';
import '../../features/individual/scanner/scanner.dart';
import '../../features/individual/leads/leads.dart';
import '../../features/individual/analytics/analytics.dart';
import '../../features/individual/campaigns/campaign.dart';
import '../../features/individual/connectors/connectors.dart';
import '../../features/individual/settings/settings.dart';
import '../../features/individual/settings/subscription/subscription_screen.dart';
import '../../features/individual/notification/notification.dart';
import '../../features/individual/approvals/approvals.dart';
import '../../features/individual/companies/companies.dart';
import '../../features/individual/workforce/workforce.dart';

// Enterprise Imports
import '../../features/enterprise/dashboard/dashboard.dart';
import '../../features/enterprise/workspace/workspace.dart';
import '../../features/enterprise/leads/leads.dart';
import '../../features/enterprise/campaigns/campaign.dart';
import '../../features/enterprise/analytics/analytics.dart';
import '../../features/enterprise/connectors/connectors.dart';
import '../../features/enterprise/brand_profile/profile.dart';
import '../../features/enterprise/settings/settings.dart';

// Master Admin Imports
import '../../features/master_admin/dashboard/dashboard.dart';
import '../../features/master_admin/companies/company.dart';
import '../../features/master_admin/companies/company_detail.dart';
import '../../features/master_admin/approvals/approval.dart';
import '../../features/master_admin/individuals/individuals.dart';
import '../../features/master_admin/leads_audit/leads.dart';
import '../../features/master_admin/campaigns/campaign.dart';
import '../../features/master_admin/analytics/analytics.dart';
import '../../features/master_admin/workspace/workspace.dart';
import '../../features/master_admin/profile/profile.dart';
import '../../features/master_admin/settings/settings.dart';

// Shell Layout Imports
import '../../widgets/shells/portal_shell.dart';
import '../../widgets/shells/enterprise_shell.dart';
import '../../widgets/shells/master_admin_shell.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, _) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final loggedIn = authState.isLoggedIn;
    final role = authState.role; // individual, enterprise, employee, master-admin
    final path = state.matchedLocation;

    final publicPaths = [
      '/',
      '/about',
      '/features',
      '/pricing',
      '/contact',
      '/blog',
      '/privacy',
      '/terms',
      '/enterprise-info'
    ];
    final authPaths = [
      '/login',
      '/signup',
      '/join-workspace',
      '/onboarding',
      '/onboarding-wizard',
      '/reset-password'
    ];

    final isPublicCard = path.startsWith('/card/');

    if (publicPaths.contains(path) || authPaths.contains(path) || isPublicCard) {
      return null; // no guard needed
    }

    if (!loggedIn) return '/login';

    if (path.startsWith('/master-admin') && role != 'master-admin') {
      return '/portal';
    }
    if (path.startsWith('/enterprise') && role != 'enterprise' && role != 'employee') {
      return '/portal';
    }
    if (path.startsWith('/portal') && role == 'master-admin') {
      return '/master-admin/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Public & Marketing
      GoRoute(path: '/', builder: (c, s) => const LandingScreen()),
      GoRoute(path: '/about', builder: (c, s) => const AboutUsScreen()),
      GoRoute(path: '/features', builder: (c, s) => const PublicFeaturesScreen()),
      GoRoute(path: '/pricing', builder: (c, s) => const PricingPlansScreen()),
      GoRoute(path: '/contact', builder: (c, s) => const PublicContactScreen()),
      GoRoute(path: '/blog', builder: (c, s) => const BlogListingScreen()),
      GoRoute(
        path: '/blog/:slug',
        builder: (c, s) => BlogDetailScreen(slug: s.pathParameters['slug']),
      ),
      GoRoute(path: '/privacy', builder: (c, s) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (c, s) => const TermsOfServiceScreen()),
      GoRoute(
        path: '/enterprise-info',
        builder: (c, s) => const EnterpriseInfoScreen(),
      ),

      // Auth
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(
        path: '/join-workspace',
        builder: (c, s) => const JoinWorkspaceScreen(),
      ),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(
        path: '/onboarding-wizard',
        builder: (c, s) => const OnboardingWizardScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (c, s) => const ResetPasswordScreen(),
      ),

      // Public Card
      GoRoute(
        path: '/card/:slug',
        builder: (c, s) => PublicCardScreen(slug: s.pathParameters['slug']),
      ),

      // Individual Portal (ShellRoute)
      ShellRoute(
        builder: (c, s, child) => PortalShell(child: child),
        routes: [
          GoRoute(
            path: '/portal',
            builder: (c, s) => const IndividualPortalHomeScreen(),
          ),
          GoRoute(
            path: '/portal/profile',
            builder: (c, s) => const IndividualProfileEditorScreen(),
          ),
          GoRoute(
            path: '/portal/vault',
            builder: (c, s) => const IndividualVaultScreen(),
          ),
          GoRoute(
            path: '/portal/scanner',
            builder: (c, s) => const IndividualScannerScreen(),
          ),
          GoRoute(
            path: '/portal/leads',
            builder: (c, s) => const IndividualLeadsScreen(),
          ),
          GoRoute(
            path: '/portal/analytics',
            builder: (c, s) => const IndividualAnalyticsScreen(),
          ),
          GoRoute(
            path: '/portal/campaign',
            builder: (c, s) => const IndividualCampaignScreen(),
          ),
          GoRoute(
            path: '/portal/connectors',
            builder: (c, s) => const IndividualConnectorsScreen(),
          ),
          GoRoute(
            path: '/portal/settings',
            builder: (c, s) => const IndividualSettingsScreen(),
          ),
          GoRoute(
            path: '/portal/subscription',
            builder: (c, s) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: '/portal/notifications',
            builder: (c, s) => const IndividualNotificationScreen(),
          ),
          GoRoute(
            path: '/portal/approvals',
            builder: (c, s) => const IndividualApprovalsScreen(),
          ),
          GoRoute(
            path: '/portal/companies',
            builder: (c, s) => const IndividualCompaniesScreen(),
          ),
          GoRoute(
            path: '/portal/workforce',
            builder: (c, s) => const IndividualWorkforceScreen(),
          ),
        ],
      ),

      // Enterprise Portal (ShellRoute)
      ShellRoute(
        builder: (c, s, child) => EnterpriseShell(child: child),
        routes: [
          GoRoute(
            path: '/enterprise/dashboard',
            builder: (c, s) => const EnterpriseDashboardScreen(),
          ),
          GoRoute(
            path: '/enterprise/workspace',
            builder: (c, s) => const EnterpriseWorkspaceScreen(),
          ),
          GoRoute(
            path: '/enterprise/leads',
            builder: (c, s) => const EnterpriseLeadsScreen(),
          ),
          GoRoute(
            path: '/enterprise/campaign',
            builder: (c, s) => const EnterpriseCampaignScreen(),
          ),
          GoRoute(
            path: '/enterprise/analytics',
            builder: (c, s) => const EnterpriseAnalyticsScreen(),
          ),
          GoRoute(
            path: '/enterprise/connectors',
            builder: (c, s) => const EnterpriseConnectorsScreen(),
          ),
          GoRoute(
            path: '/enterprise/profile',
            builder: (c, s) => const EnterpriseProfileScreen(),
          ),
          GoRoute(
            path: '/enterprise/settings',
            builder: (c, s) => const EnterpriseSettingsScreen(),
          ),
        ],
      ),

      // Master Admin Portal (ShellRoute)
      ShellRoute(
        builder: (c, s, child) => MasterAdminShell(child: child),
        routes: [
          GoRoute(
            path: '/master-admin/dashboard',
            builder: (c, s) => const MasterAdminDashboardScreen(),
          ),
          GoRoute(
            path: '/master-admin/company',
            builder: (c, s) => const MasterAdminCompanyScreen(),
          ),
          GoRoute(
            path: '/master-admin/company/:companyId',
            builder: (c, s) => MasterAdminCompanyDetailScreen(
              companyId: s.pathParameters['companyId'],
            ),
          ),
          GoRoute(
            path: '/master-admin/approval',
            builder: (c, s) => const MasterAdminApprovalScreen(),
          ),
          GoRoute(
            path: '/master-admin/individuals',
            builder: (c, s) => const MasterAdminIndividualsScreen(),
          ),
          GoRoute(
            path: '/master-admin/leads',
            builder: (c, s) => const MasterAdminLeadsScreen(),
          ),
          GoRoute(
            path: '/master-admin/campaign',
            builder: (c, s) => const MasterAdminCampaignScreen(),
          ),
          GoRoute(
            path: '/master-admin/analytics',
            builder: (c, s) => const MasterAdminAnalyticsScreen(),
          ),
          GoRoute(
            path: '/master-admin/workspace',
            builder: (c, s) => const MasterAdminWorkspaceScreen(),
          ),
          GoRoute(
            path: '/master-admin/profile',
            builder: (c, s) => const MasterAdminProfileScreen(),
          ),
          GoRoute(
            path: '/master-admin/settings',
            builder: (c, s) => const MasterAdminSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
