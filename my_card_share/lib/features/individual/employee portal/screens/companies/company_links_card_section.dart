import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyLinksCardSection extends StatelessWidget {
  final VoidCallback? onVisitWebsite;
  final VoidCallback? onContactAdmin;
  final VoidCallback? onViewWorkforce;

  const CompanyLinksCardSection({
    super.key,
    this.onVisitWebsite,
    this.onContactAdmin,
    this.onViewWorkforce,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Company Links",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Link 1: Visit Company Website
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.language_rounded, color: Color(0xFF0052FF), size: 19),
                ),
                title: const Text(
                  "Visit Company Website",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
                onTap: () {
                  if (onVisitWebsite != null) {
                    onVisitWebsite!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Opening acmerealty.com..."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // Link 2: Contact Admin
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mail_outline_rounded, color: Color(0xFFD97706), size: 19),
                ),
                title: const Text(
                  "Contact Admin",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
                onTap: () {
                  if (onContactAdmin != null) {
                    onContactAdmin!();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Contacting admin: Priya Sharma (priya@acmerealty.com)"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9)),

              // Link 3: View Team Workforce
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.groups_rounded, color: Color(0xFF059669), size: 19),
                ),
                title: const Text(
                  "View Team Workforce",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
                onTap: () {
                  if (onViewWorkforce != null) {
                    onViewWorkforce!();
                  } else {
                    context.push('/portal/workforce');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
