import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'leads_screen.dart' as ind_leads;
import '../../employee/leads/leads_screen.dart' as emp_leads;

export 'leads_screen.dart';
export 'widgets/leads_header.dart';
export 'widgets/leads_metrics_row.dart';
export 'widgets/leads_search_bar.dart';
export 'widgets/leads_filter_pills.dart';
export 'widgets/lead_list_tile.dart';

class IndividualLeadsScreen extends ConsumerWidget {
  const IndividualLeadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role.toLowerCase();
    if (role == 'employee') {
      return const emp_leads.LeadsScreen();
    }
    return const ind_leads.LeadsScreen();
  }
}


