import 'package:flutter/material.dart';

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

  static const List<Map<String, dynamic>> _allEmployees = [
    {
      "id": "1",
      "name": "Alex Stanton",
      "jobTitle": "Chief Operations Officer",
      "email": "alex.stanton@acmerealty.com",
      "role": "Admin",
      "status": "Active",
      "initials": "AS",
      "avatarColor": Color(0xFF7C3AED),
      "bgAvatarColor": Color(0xFFF3E8FF),
    },
    {
      "id": "2",
      "name": "Sarah Jenkins",
      "jobTitle": "Senior Real Estate Agent",
      "email": "sarah.j@acmerealty.com",
      "role": "Admin",
      "status": "Active",
      "initials": "SJ",
      "avatarColor": Color(0xFF0052FF),
      "bgAvatarColor": Color(0xFFEFF4FF),
    },
    {
      "id": "3",
      "name": "David Miller",
      "jobTitle": "Property Manager",
      "email": "david.m@acmerealty.com",
      "role": "Employee",
      "status": "Active",
      "initials": "DM",
      "avatarColor": Color(0xFF0D9488),
      "bgAvatarColor": Color(0xFFCCFBF1),
    },
    {
      "id": "4",
      "name": "Emily Turner",
      "jobTitle": "Commercial Specialist",
      "email": "emily.t@acmerealty.com",
      "role": "Employee",
      "status": "Active",
      "initials": "ET",
      "avatarColor": Color(0xFF2563EB),
      "bgAvatarColor": Color(0xFFDBEAFE),
    },
    {
      "id": "5",
      "name": "Michael Ross",
      "jobTitle": "Broker Associate",
      "email": "michael.r@acmerealty.com",
      "role": "Employee",
      "status": "Pending Invite",
      "initials": "MR",
      "avatarColor": Color(0xFFD97706),
      "bgAvatarColor": Color(0xFFFEF3C7),
    },
  ];

  List<Map<String, dynamic>> get _filteredEmployees {
    return _allEmployees.where((emp) {
      // Role / Status Filter
      if (selectedFilter == "Admins" && emp["role"] != "Admin") return false;
      if (selectedFilter == "Employees" && emp["role"] != "Employee") return false;
      if (selectedFilter == "Pending" && emp["status"] != "Pending Invite") return false;

      // Search Query Filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final name = (emp["name"] as String).toLowerCase();
        final email = (emp["email"] as String).toLowerCase();
        final title = (emp["jobTitle"] as String).toLowerCase();
        return name.contains(query) || email.contains(query) || title.contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final employees = _filteredEmployees;

    if (employees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              "No employees found",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try adjusting your search or filter options",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: employees.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF1F5F9),
        ),
        itemBuilder: (context, index) {
          final emp = employees[index];
          final isPending = emp["status"] == "Pending Invite";
          final isAdmin = emp["role"] == "Admin";

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Circular Avatar / Initials
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: emp["bgAvatarColor"] as Color,
                    shape: BoxShape.circle,
                    border: isPending
                        ? Border.all(color: const Color(0xFFFDE68A), width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emp["initials"] as String,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: emp["avatarColor"] as Color,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Employee Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        emp["name"] as String,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Job Title & Email
                      Text(
                        "${emp["jobTitle"]} · ${emp["email"]}",
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Status Indicator (Green dot "Active" or Amber dot "Pending Invite")
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isPending
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            emp["status"] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isPending
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Role Tag Pill & 3-dot overflow menu
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Role Tag Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? const Color(0xFFF3E8FF)
                            : const Color(0xFFEFF4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emp["role"] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isAdmin
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFF0052FF),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // 3-dot Overflow Menu
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (action) {
                        if (onActionSelected != null) {
                          onActionSelected!(emp, action);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0F172A)),
                              SizedBox(width: 8),
                              Text("Edit Details", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: isPending ? "resend" : "deactivate",
                          child: Row(
                            children: [
                              Icon(
                                isPending ? Icons.send_rounded : Icons.block_rounded,
                                size: 16,
                                color: isPending
                                    ? const Color(0xFF0052FF)
                                    : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isPending ? "Resend Invite" : "Deactivate",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isPending
                                      ? const Color(0xFF0052FF)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
