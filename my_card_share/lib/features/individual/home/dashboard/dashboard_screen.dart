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

import '../../../../core/theme/app_theme.dart';

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
    // When returning to Home from any secondary route, reset temporary Home UI state
    _resetView();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeroCard(
                name: "Alex Stanton",
                role: "Product Designer",
                company: "Acme Realty Group",
                onViewMyCardTap: _toggleViewMyCard,
              ),
              const SizedBox(height: 20),
              const DashboardMetricsRow(),
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
  }
}
