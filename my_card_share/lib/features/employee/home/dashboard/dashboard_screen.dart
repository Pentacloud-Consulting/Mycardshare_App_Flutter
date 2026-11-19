import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_card_share/core/router/app_router.dart';
import 'package:my_card_share/features/individual/scanner/widgets/camera_scan_modal.dart';
import 'package:my_card_share/services/Individual/voice/voice.dart';
import 'package:my_card_share/features/public_card/public_card_screen.dart';
import 'dashboard_hero_card.dart';
import 'dashboard_metrics_row.dart';
import 'dashboard_quick_actions.dart';
import 'dashboard_recent_leads.dart';
import 'widgets/dashboard_digital_wallet.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';
import '../../../../backend/individual/multiple_store/individual_multi_store.dart';
import '../../../../backend/individual/previews/individual_metrics_store.dart';
import '../../../../backend/individual/previews/publish_unpublish.dart';
import '../../../../backend/employee_join/home/employee_home_backend.dart';
import '../../../../backend/employee_join/home/employee_stats_backend.dart';
import '../../../../backend/employee_join/banner fetch/banner fetch.dart';
import '../../../../backend/employee_join/employee_sync_service.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';
import '../../../../backend/enterprise/multiple_store/enterprise_multi_store.dart';
import '../../../../core/utils/image_url_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static _DashboardScreenState? _activeState;

  static bool resetViewIfOpen() {
    if (_activeState != null && _activeState!._showingCardView) {
      _activeState!._resetView();
      return true;
    }
    return false;
  }

  static void resetToDefaultHome() {
    _activeState?._resetView();
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  bool _showingCardView = false;

  @override
  void initState() {
    super.initState();
    DashboardScreen._activeState = this;
    
    // Load real Employee Home & Stats Backend Services
    EmployeeHomeBackendService.instance.loadEmployeeHomeData();
    EmployeeStatsBackendService.instance.loadEmployeeStats();
    EmployeeBannerFetchService.instance.fetchEnterpriseBrand();
    EmployeeSyncService.instance.fetchEmployeeSyncData();

    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      IndividualProfileStore.instance.loadProfile(
        fbUser.uid,
        fbUser.email ?? '',
        fbUser.displayName ?? '',
      );
      IndividualMetricsStore.instance.loadMetrics(fbUser.uid);
      PublishUnpublishService.instance.loadPublishStatus(fbUser.uid);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    if (DashboardScreen._activeState == this) {
      DashboardScreen._activeState = null;
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _resetView();
    EmployeeHomeBackendService.instance.loadEmployeeHomeData();
    EmployeeBannerFetchService.instance.fetchEnterpriseBrand();
    final fbUser = FirebaseAuth.instance.currentUser;
    if (fbUser != null) {
      IndividualProfileStore.instance.loadProfile(
        fbUser.uid,
        fbUser.email ?? '',
        fbUser.displayName ?? '',
      );
      // Reload metrics for the current user so the dashboard cards reflect
      // the latest data (and don't show stale data from a previous user).
      IndividualMetricsStore.instance.loadMetrics(fbUser.uid);
    }
  }

  void _resetView() {
    if (mounted && _showingCardView) {
      setState(() {
        _showingCardView = false;
      });
    }
  }

  void _toggleViewMyCard() {
    setState(() {
      _showingCardView = !_showingCardView;
    });
  }

  void _openScanCard() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CameraScanModal(),
      ),
    );
  }

  void _openVoiceAdd() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const VoiceScanModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showingCardView) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: PublicCardScreen(showBottomNav: false),
      );
    }

    return ListenableBuilder(
      listenable: Listenable.merge([
        IndividualProfileStore.instance,
        PublishUnpublishService.instance,
        EmployeeHomeBackendService.instance,
        EmployeeStatsBackendService.instance,
        EmployeeBannerFetchService.instance,
      ]),
      builder: (context, _) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final empBackend = EmployeeHomeBackendService.instance;
        final userEmail = firebaseUser?.email?.toLowerCase() ?? empBackend.email.toLowerCase();

        final activeProfile = IndividualProfileStore.instance.activeProfile;
        final isSameUser = activeProfile != null &&
            ((firebaseUser != null && activeProfile.uid == firebaseUser.uid) ||
             (userEmail.isNotEmpty && activeProfile.email.toLowerCase() == userEmail));
        final validActive = isSameUser ? activeProfile : null;

        final storedUser = userEmail.isNotEmpty
            ? (IndividualMultiStore.instance.getUser(userEmail) ??
               IndividualMultiStore.instance.getAllUsers().cast<IndividualUserRecord?>().firstWhere(
                 (u) => u?.email.toLowerCase() == userEmail,
                 orElse: () => null,
               ))
            : null;

        final isPublished = PublishUnpublishService.instance.isPublished;
        final brandFetch = EmployeeBannerFetchService.instance;

        final displayName = (empBackend.userName.isNotEmpty && empBackend.userName != "User")
            ? empBackend.userName
            : ((validActive?.fullName.isNotEmpty == true && validActive!.fullName != "User")
                ? validActive!.fullName
                : ((storedUser?.fullName.isNotEmpty == true ? storedUser!.fullName : null)
                    ?? (firebaseUser?.displayName?.isNotEmpty == true ? firebaseUser!.displayName : null)
                    ?? (userEmail.isNotEmpty ? userEmail.split('@').first : "Employee")));

        final rawPhoto = (validActive?.profilePhoto?.isNotEmpty == true ? validActive!.profilePhoto : null)
            ?? (empBackend.avatarUrl?.isNotEmpty == true ? empBackend.avatarUrl : null)
            ?? (firebaseUser?.photoURL?.isNotEmpty == true ? firebaseUser!.photoURL : null);
        final displayPhoto = ImageUrlFormatter.format(rawPhoto);

        final rawUserBanner = (validActive?.bannerPhoto?.isNotEmpty == true ? validActive!.bannerPhoto : null);
        final displayBanner = brandFetch.getEffectiveBanner(rawUserBanner) ?? rawUserBanner;

        final displayRole = (empBackend.role.isNotEmpty && empBackend.role != "Member" && empBackend.role != "Employee")
            ? empBackend.role
            : ((validActive?.jobTitle.isNotEmpty == true && validActive!.jobTitle != "Member" && validActive!.jobTitle != "Employee")
                ? validActive!.jobTitle
                : '');

        final activeEntProfile = EnterpriseProfileStore.instance.currentProfile;
        final isSameEnt = activeEntProfile != null &&
            (userEmail.isNotEmpty && activeEntProfile.email.toLowerCase() == userEmail);
        final validEntProfile = isSameEnt ? activeEntProfile : null;

        final entMultiUsers = EnterpriseMultiStore.instance.getAllUsers();
        final matchedMultiUser = userEmail.isNotEmpty
            ? entMultiUsers.cast<EnterpriseUserRecord?>().firstWhere(
                (u) => u?.email.toLowerCase() == userEmail,
                orElse: () => null,
              )
            : null;

        final displayCompany = (empBackend.companyName.isNotEmpty && empBackend.companyName != "Enterprise Workspace" && empBackend.companyName != "Acme Realty")
            ? empBackend.companyName
            : ((validActive?.companyName.isNotEmpty == true && validActive!.companyName != "Enterprise Workspace" ? validActive.companyName : null)
                ?? (validEntProfile?.companyName.isNotEmpty == true && validEntProfile!.companyName != "Enterprise Workspace" ? validEntProfile.companyName : null)
                ?? (matchedMultiUser?.companyName.isNotEmpty == true && matchedMultiUser!.companyName != "Enterprise Workspace" ? matchedMultiUser.companyName : null)
                ?? "Enterprise Workspace");

        final displayStatus = empBackend.status.isNotEmpty ? empBackend.status : "Actively Networking";
        final templateIndex = IndividualProfileStore.getTemplateIndex(validActive?.templateStyle);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardHeroCard(
                    name: displayName,
                    profilePhoto: displayPhoto,
                    bannerPhoto: displayBanner,
                    role: displayRole,
                    company: displayCompany,
                    status: displayStatus,
                    selectedTemplateIndex: templateIndex,
                    isPublished: isPublished,
                    onViewMyCardTap: _toggleViewMyCard,
                  ),
                  const SizedBox(height: 20),
                  const DashboardMetricsRow(),
                  const SizedBox(height: 24),
                  const DashboardDigitalWallet(),
                  const SizedBox(height: 24),
                  DashboardQuickActions(
                    onScanCardTap: _openScanCard,
                    onVoiceAddTap: _openVoiceAdd,
                    onAnalyticsTap: () => context.push('/portal/analytics'),
                    onVaultTap: () => context.push('/portal/vault'),
                  ),
                  const SizedBox(height: 24),
                  DashboardRecentLeads(
                    onSeeAllTap: () => context.push('/portal/leads'),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


