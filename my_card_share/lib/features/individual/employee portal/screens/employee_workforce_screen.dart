import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../auth/font style/font_style.dart';
import 'workforce/workforce_summary_card_section.dart';
import 'workforce/workforce_search_and_filters_section.dart';
import 'workforce/workforce_teammates_list_section.dart';
import 'workforce/workforce_footer_caption_section.dart';

class EmployeeWorkforceScreen extends StatefulWidget {
  const EmployeeWorkforceScreen({super.key});

  @override
  State<EmployeeWorkforceScreen> createState() => _EmployeeWorkforceScreenState();
}

class _EmployeeWorkforceScreenState extends State<EmployeeWorkforceScreen> {
  String _searchQuery = "";
  String _selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    final filteredTeammates =
        WorkforceTeammatesListSection.defaultTeammates.where((member) {
      final q = _searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          member.name.toLowerCase().contains(q) ||
          member.jobTitle.toLowerCase().contains(q) ||
          member.department.toLowerCase().contains(q);

      if (!matchesQuery) return false;

      if (_selectedFilter == "Admins") {
        return member.role == "Admin";
      } else if (_selectedFilter == "My Department") {
        return member.department == "Sales" || member.department == "Executive";
      }

      return true;
    }).toList();

    return SmartPopScope(
      onBack: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/portal');
        }
        return true;
      },
      child: Scaffold(
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
                    const WorkforceSummaryCardSection(
                      companyName: "Acme Realty Group",
                      logoText: "AR",
                      memberCountText: "34 members",
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
      ),
    );
  }
}
