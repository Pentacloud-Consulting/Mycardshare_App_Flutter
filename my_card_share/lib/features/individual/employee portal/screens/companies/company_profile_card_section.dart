import 'package:flutter/material.dart';

class CompanyProfileCardSection extends StatelessWidget {
  final String companyName;
  final String logoInitials;
  final String planTag;
  final String employeeCount;

  const CompanyProfileCardSection({
    super.key,
    this.companyName = "Acme Realty Group",
    this.logoInitials = "AR",
    this.planTag = "Enterprise Pro",
    this.employeeCount = "34 employees",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Image (Blue-Purple Gradient Cover)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0052FF), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                ),
              ),

              // Overlapping Logo Circle
              Positioned(
                bottom: -32,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0052FF),
                    border: Border.all(color: Colors.white, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      logoInitials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 42),

          // Company Name & Badges
          Text(
            companyName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(height: 8),

          // Enterprise Pro Blue Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              planTag.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0052FF),
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Employee Count Subtext
          Text(
            employeeCount,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
