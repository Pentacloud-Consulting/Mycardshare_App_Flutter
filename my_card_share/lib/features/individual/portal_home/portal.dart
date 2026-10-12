import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../home/dashboard/dashboard.dart' as ind_dashboard;
import '../../employee/home/dashboard/dashboard.dart' as emp_dashboard;

class IndividualPortalHomeScreen extends ConsumerWidget {
  const IndividualPortalHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role.toLowerCase();
    if (role == 'employee') {
      return const emp_dashboard.DashboardScreen();
    }
    return const ind_dashboard.DashboardScreen();
  }
}
