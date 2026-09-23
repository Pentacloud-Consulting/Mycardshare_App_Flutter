import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../auth/font style/font_style.dart';
import 'companies/company_profile_card_section.dart';
import 'companies/company_info_grid_section.dart';
import 'companies/company_branding_card_section.dart';
import 'companies/company_links_card_section.dart';

class EmployeeCompaniesScreen extends StatelessWidget {
  const EmployeeCompaniesScreen({super.key});

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
                    // 1. Company Profile Card Section
                    const CompanyProfileCardSection(
                      companyName: "Acme Realty Group",
                      logoInitials: "AR",
                      planTag: "Enterprise Pro",
                      employeeCount: "34 employees",
                    ),

                    const SizedBox(height: 18),

                    // 2. 2x2 Info Grid Section
                    const CompanyInfoGridSection(
                      location: "New York, NY",
                      website: "acmerealty.com",
                      role: "Employee",
                      joinedDate: "March 2026",
                    ),

                    const SizedBox(height: 20),

                    // 3. Your Card Branding Section
                    const CompanyBrandingCardSection(),

                    const SizedBox(height: 20),

                    // 4. Company Links Section
                    CompanyLinksCardSection(
                      onVisitWebsite: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Opening acmerealty.com..."),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onContactAdmin: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Contacting admin: Priya Sharma (priya@acmerealty.com)"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onViewWorkforce: () {
                        context.push('/portal/workforce');
                      },
                    ),

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
