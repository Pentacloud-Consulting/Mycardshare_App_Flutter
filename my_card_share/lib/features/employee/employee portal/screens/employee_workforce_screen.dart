import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../auth/font style/font_style.dart';
import 'workforce/workforce_summary_card_section.dart';
import 'workforce/workforce_search_and_filters_section.dart';
import 'workforce/workforce_teammates_list_section.dart';
import 'workforce/workforce_footer_caption_section.dart';
import '../../../../backend/employee_join/home/employee_home_backend.dart';
import '../../../../backend/enterprise/profile/enterprise_profile_store.dart';

class EmployeeWorkforceScreen extends StatefulWidget {
  const EmployeeWorkforceScreen({super.key});

  @override
  State<EmployeeWorkforceScreen> createState() => _EmployeeWorkforceScreenState();
}

class _EmployeeWorkforceScreenState extends State<EmployeeWorkforceScreen> {
  String _searchQuery = "";
  String _selectedFilter = "All";

  Stream<List<TeammateModel>> _getRealTeammatesStream() {
    final empBackend = EmployeeHomeBackendService.instance;
    final user = FirebaseAuth.instance.currentUser;
    final entUid = (empBackend.enterpriseUid != null && empBackend.enterpriseUid!.trim().isNotEmpty)
        ? empBackend.enterpriseUid!.trim()
        : (EnterpriseProfileStore.instance.currentProfile?.uid ?? user?.uid ?? '');

    if (entUid.isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('enterprises')
        .doc(entUid)
        .collection('employees')
        .snapshots()
        .map((snapshot) {
      final List<TeammateModel> list = [];
      const colors = [
        Color(0xFF0052FF),
        Color(0xFF8B5CF6),
        Color(0xFF0D9488),
        Color(0xFFD97706),
        Color(0xFF10B981),
        Color(0xFF7E22CE),
        Color(0xFFEF4444),
      ];

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final name = (data['name'] ?? data['fullName'] ?? 'Team Member').toString().trim();
        final roleTitle = (data['roleTitle'] ?? data['jobTitle'] ?? 'Employee').toString().trim();
        final role = (data['role'] ?? 'Employee').toString().trim();
        final dept = (data['department'] ?? 'General').toString().trim();
        final slug = (data['cardSlug'] ?? data['slug'] ?? doc.id).toString().trim();
        final avatar = (data['avatarUrl'] ?? data['profilePhoto'])?.toString();

        String initials = 'TM';
        if (name.isNotEmpty) {
          final parts = name.split(RegExp(r'\s+'));
          initials = parts.length > 1
              ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
              : parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
        }

        list.add(
          TeammateModel(
            id: doc.id,
            name: name,
            jobTitle: roleTitle,
            role: role,
            department: dept,
            avatarText: initials,
            avatarBg: colors[i % colors.length],
            slug: slug,
            avatarUrl: avatar,
          ),
        );
      }
      return list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SmartPopScope(
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/portal');
        }
        return true;
      },
      child: StreamBuilder<List<TeammateModel>>(
        stream: _getRealTeammatesStream(),
        builder: (context, snapshot) {
          final allTeammates = snapshot.data ?? [];
          final empBackend = EmployeeHomeBackendService.instance;
          final resolvedCompanyName = (empBackend.companyName.isNotEmpty &&
                  empBackend.companyName != "Enterprise Workspace")
              ? empBackend.companyName
              : "My Workspace";

          final cleanLogo = resolvedCompanyName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

          final filteredTeammates = allTeammates.where((member) {
            final q = _searchQuery.toLowerCase().trim();
            final matchesQuery = q.isEmpty ||
                member.name.toLowerCase().contains(q) ||
                member.jobTitle.toLowerCase().contains(q) ||
                member.department.toLowerCase().contains(q);

            if (!matchesQuery) return false;

            if (_selectedFilter == "Admins") {
              return member.role.toLowerCase() == "admin";
            } else if (_selectedFilter == "My Department") {
              return member.department.toLowerCase() == "sales" || member.department.toLowerCase() == "executive";
            }

            return true;
          }).toList();

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                // Soft baby-blue gradient blob top-right corner
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFDBEAFE).withValues(alpha: 0.75),
                          const Color(0xFFEFF6FF).withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: DefaultTextStyle(
                    style: AppFontStyle.bodyMedium,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Summary Card Section
                          WorkforceSummaryCardSection(
                            companyName: resolvedCompanyName,
                            logoText: cleanLogo.isNotEmpty ? cleanLogo : "WS",
                            memberCountText: "${allTeammates.length} ${allTeammates.length == 1 ? 'member' : 'members'}",
                          ),

                          const SizedBox(height: 14),

                          // 2. Search Bar + Filter Chips Section
                          WorkforceSearchAndFiltersSection(
                            selectedFilter: _selectedFilter,
                            onSearchChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            onFilterSelected: (filter) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // 3. Teammates List Section (View-only directory)
                          WorkforceTeammatesListSection(
                            teammates: filteredTeammates,
                            onTeammateTap: (member) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Viewing ${member.name}'s digital card"),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: "Open Card",
                                    textColor: const Color(0xFF38BDF8),
                                    onPressed: () {
                                      context.push('/card/${member.slug}');
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // 4. View-Only Directory Footer Caption
                          const WorkforceFooterCaptionSection(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


