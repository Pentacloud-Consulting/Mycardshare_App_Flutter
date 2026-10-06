import 'package:flutter/material.dart';

import '../../../backend/enterprise/home backend/employees_page.dart';
import 'widgets/workspace_search_filter.dart';
import 'widgets/workspace_filter_chips.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterpriseWorkspaceScreen extends StatefulWidget {
  const EnterpriseWorkspaceScreen({super.key});

  @override
  State<EnterpriseWorkspaceScreen> createState() => _EnterpriseWorkspaceScreenState();
}

class _EnterpriseWorkspaceScreenState extends State<EnterpriseWorkspaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final titleController = TextEditingController();
    String role = 'Employee';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.person_add_rounded, color: Color(0xFF0052FF)),
              SizedBox(width: 10),
              Text(
                "Invite Employee",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    hintText: "e.g. Sarah Jenkins",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Work Email",
                    hintText: "e.g. sarah@company.com",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Job Title",
                    hintText: "e.g. Senior Real Estate Agent",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(
                    labelText: "Access Role",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Employee', child: Text("Employee")),
                    DropdownMenuItem(value: 'Admin', child: Text("Admin")),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => role = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null || nameController.text.trim().isEmpty) return;

                final invitedName = nameController.text;
                final messenger = ScaffoldMessenger.of(context);
                final success = await EnterpriseEmployeesService.instance.addEmployee(
                  uid: uid,
                  name: invitedName,
                  email: emailController.text,
                  roleTitle: titleController.text.isEmpty
                      ? "Employee"
                      : titleController.text,
                  role: role,
                );

                if (ctx.mounted) Navigator.pop(ctx);
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text("Invited $invitedName successfully!"),
                      backgroundColor: const Color(0xFF16A34A),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              child: const Text("Send Invite", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: GestureDetector(
          onTap: _showAddEmployeeDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  "Invite",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Top-right soft baby-blue gradient blob
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38BDF8).withValues(alpha: 0.16),
                    const Color(0xFF0052FF).withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Dynamic Stat Pills Row (Image 4: Total, Active, Pending)
                  EnterpriseStatsPillsWidget(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 2. Search Bar + Filter Icon Button
                  WorkspaceSearchFilter(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    onFilterTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Filter options opened"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 3. Horizontal Scrollable Filter Chips (All, Admins, Employees, Pending)
                  WorkspaceFilterChips(
                    selectedFilter: _selectedFilter,
                    onSelected: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // 4. Real Employee List Card (Image 5)
                  EnterpriseEmployeeListBackend(
                    searchQuery: _searchQuery,
                    selectedFilter: _selectedFilter,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
