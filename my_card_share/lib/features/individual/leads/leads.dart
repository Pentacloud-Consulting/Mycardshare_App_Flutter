import 'package:flutter/material.dart';
import 'leads_screen.dart';

export 'leads_screen.dart';
export 'widgets/leads_header.dart';
export 'widgets/leads_metrics_row.dart';
export 'widgets/leads_search_bar.dart';
export 'widgets/leads_filter_pills.dart';
export 'widgets/lead_list_tile.dart';

class IndividualLeadsScreen extends StatelessWidget {
  const IndividualLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeadsScreen();
  }
}
