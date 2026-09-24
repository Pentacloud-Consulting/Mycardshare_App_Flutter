import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';


// Auth Imports
import '../../features/auth/login/login.dart';
import '../../features/auth/signup/signup.dart';
import '../../features/auth/join_workspace/join_workspace.dart';
import '../../features/auth/onboarding/onboarding.dart';
import '../../features/auth/reset_password/reset_password.dart';
import '../../features/auth/enterprice sign/registration_pending_screen.dart';
import '../../features/auth/enterprice sign/enterprise_onboarding_screen.dart';
import '../../features/auth/master_admin/master_admin_login.dart';

// Public Card Import
import '../../features/public_card/card.dart';

// Individual / Portal Imports
import '../../features/individual/form/individual_onboarding_form.dart';
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
import '../../features/individual/settings/widgets/support/help_and_support_screen.dart';
import '../../features/individual/settings/widgets/support/terms_of_service_screen.dart';
import '../../features/individual/settings/widgets/support/privacy_policy_screen.dart';
import '../../features/individual/settings/widgets/support/about_screen.dart';
import '../../features/individual/notification/notification.dart';
import '../../features/individual/approvals/approvals.dart';
import '../../features/individual/companies/companies.dart';
import '../../features/individual/workforce/workforce.dart';

// Enterprise Imports
import '../../features/enterprise/dashboard/enterprise_dashboard_screen.dart';
import '../../features/enterprise/workspace/workspace_screen.dart';
import '../../features/enterprise/leads/leads.dart';
import '../../features/enterprise/campaigns/campaign.dart';
import '../../features/enterprise/analytics/analytics.dart';
import '../../features/enterprise/connectors/connectors.dart';
import '../../features/enterprise/brand_profile/profile.dart';
import '../../features/enterprise/notifications/notifications.dart';
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
import '../../features/master_admin/notifications/master_admin_notifications_screen.dart';

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
      '/reset-password',
      '/registration-pending',
      '/enterprise-onboarding',
      '/individual/form',
      '/master-admin/login'
    ];

    final isPublicCard = path.startsWith('/card/');

    // If logged in, redirect away from auth paths (except enterprise onboarding, individual form & registration pending)
    if (loggedIn && (authPaths.contains(path) || path == '/')) {
      if (path == '/enterprise-onboarding' || path == '/registration-pending' || path == '/individual/form') {
        return null; // allow viewing onboarding wizard & pending screens
      }
      if (role == 'master-admin') {
        return '/master-admin/dashboard';
      }
      if (role == 'enterprise' || role == 'employee') {
        return '/enterprise/dashboard';
      }
      return '/portal'; // individual
    }

    if (publicPaths.contains(path) || authPaths.contains(path) || isPublicCard) {
      return null; // no guard needed
    }

    if (!loggedIn) return '/onboarding'; // unauthenticated users should see onboarding first

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

final appRouteObserver = RouteObserver<ModalRoute<void>>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    observers: [appRouteObserver],
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Public & Marketing
      GoRoute(path: '/', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/about', builder: (c, s) => const AboutScreen()),
      GoRoute(path: '/privacy', builder: (c, s) => const SupportPrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (c, s) => const SupportTermsOfServiceScreen()),

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
      GoRoute(
        path: '/registration-pending',
        builder: (c, s) => const RegistrationPendingScreen(),
      ),
      GoRoute(
        path: '/enterprise-onboarding',
        builder: (c, s) => const EnterpriseOnboardingScreen(),
      ),
      GoRoute(
        path: '/individual/form',
        builder: (c, s) => const IndividualOnboardingFormScreen(),
      ),
      GoRoute(
        path: '/master-admin/login',
        builder: (c, s) => const MasterAdminLoginScreen(),
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
            path: '/portal/support/help',
            builder: (c, s) => const HelpAndSupportScreen(),
          ),
          GoRoute(
            path: '/portal/support/terms',
            builder: (c, s) => const SupportTermsOfServiceScreen(),
          ),
          GoRoute(
            path: '/portal/support/privacy',
            builder: (c, s) => const SupportPrivacyPolicyScreen(),
          ),
          GoRoute(
            path: '/portal/support/about',
            builder: (c, s) => const AboutScreen(),
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
            builder: (c, s) => const EnterpriseCampaignsScreen(),
          ),
          GoRoute(
            path: '/enterprise/campaigns',
            builder: (c, s) => const EnterpriseCampaignsScreen(),
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
            path: '/enterprise/brand-profile',
            builder: (c, s) => const EnterpriseBrandProfileScreen(),
          ),
          GoRoute(
            path: '/enterprise/notifications',
            builder: (c, s) => const EnterpriseNotificationsScreen(),
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
          GoRoute(
            path: '/master-admin/notifications',
            builder: (c, s) => const MasterAdminNotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});
