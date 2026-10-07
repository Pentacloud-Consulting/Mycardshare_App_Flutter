import 'package:flutter/material.dart';
import '../../../../backend/enterprise/home_backend/employees_page.dart';

class WorkspaceEmployeeList extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final Function(Map<String, dynamic> employee, String action)? onActionSelected;

  const WorkspaceEmployeeList({
    super.key,
    this.searchQuery = "",
    this.selectedFilter = "All",
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return EnterpriseEmployeeListBackend(
      searchQuery: searchQuery,
      selectedFilter: selectedFilter,
    );
  }
}


