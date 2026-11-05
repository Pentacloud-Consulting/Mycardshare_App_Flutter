import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'analytics_screen.dart' as ind_analytics;
import '../../employee/analytics/analytics_screen.dart' as emp_analytics;

class IndividualAnalyticsScreen extends ConsumerWidget {
  const IndividualAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role.toLowerCase();
    if (role == 'employee') {
      return const emp_analytics.AnalyticsScreen();
    }
    return const ind_analytics.AnalyticsScreen();
  }
}


