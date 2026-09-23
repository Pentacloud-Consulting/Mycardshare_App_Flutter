import 'package:flutter/material.dart';

class TeammateModel {
  final String id;
  final String name;
  final String jobTitle;
  final String role; // Admin or Employee
  final String department;
  final String avatarText;
  final Color avatarBg;
  final String slug;

  const TeammateModel({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.role,
    required this.department,
    required this.avatarText,
    required this.avatarBg,
    required this.slug,
  });
}

class WorkforceTeammatesListSection extends StatelessWidget {
  final List<TeammateModel> teammates;
  final ValueChanged<TeammateModel>? onTeammateTap;

  const WorkforceTeammatesListSection({
    super.key,
    required this.teammates,
    this.onTeammateTap,
  });

  static const List<TeammateModel> defaultTeammates = [
    TeammateModel(
      id: 't-1',
      name: 'Priya Sharma',
      jobTitle: 'VP Operations & Admin',
      role: 'Admin',
      department: 'Executive',
      avatarText: 'PS',
      avatarBg: Color(0xFF8B5CF6),
      slug: 'priya-sharma',
    ),
    TeammateModel(
      id: 't-2',
      name: 'Alex Johnson',
      jobTitle: 'Senior Managing Director',
      role: 'Employee',
      department: 'Sales',
      avatarText: 'AJ',
      avatarBg: Color(0xFF0052FF),
      slug: 'alex-johnson',
    ),
    TeammateModel(
      id: 't-3',
      name: 'Marcus Vance',
      jobTitle: 'Creative Director',
      role: 'Employee',
      department: 'Design',
      avatarText: 'MV',
      avatarBg: Color(0xFF0D9488),
      slug: 'marcus-vance',
    ),
    TeammateModel(
      id: 't-4',
      name: 'Elena Rostova',
      jobTitle: 'Lead Financial Analyst',
      role: 'Employee',
      department: 'Finance',
      avatarText: 'ER',
      avatarBg: Color(0xFFD97706),
      slug: 'elena-rostova',
    ),
    TeammateModel(
      id: 't-5',
      name: 'David Miller',
      jobTitle: 'Systems Architect',
      role: 'Employee',
      department: 'Engineering',
      avatarText: 'DM',
      avatarBg: Color(0xFF10B981),
      slug: 'david-miller',
    ),
    TeammateModel(
      id: 't-6',
      name: 'Fatima Al-Zahrawi',
      jobTitle: 'Platform Super Admin',
      role: 'Admin',
      department: 'Executive',
      avatarText: 'FA',
      avatarBg: Color(0xFF7E22CE),
      slug: 'fatima-al-zahrawi',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (teammates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              "No Teammates Found",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            SizedBox(height: 4),
            Text(
              "Try changing your search terms or filter selection.",
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
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: teammates.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          final isLast = index == teammates.length - 1;
          final isAdmin = member.role == "Admin";

          return Column(
            children: [
              InkWell(
                onTap: () => onTeammateTap?.call(member),
                borderRadius: index == 0
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : isLast
                        ? const BorderRadius.vertical(bottom: Radius.circular(16))
                        : BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Row(
                    children: [
                      // Circular Avatar (left)
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: member.avatarBg.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: member.avatarBg.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            member.avatarText,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: member.avatarBg,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name, Job Title & Green Active Dot Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981), // Active green dot
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    member.jobTitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Role Tag Pill (Purple for Admin, Blue for Employee)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAdmin ? const Color(0xFFF3E8FF) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAdmin ? const Color(0xFFDDD6FE) : const Color(0xFFBFDBFE),
                          ),
                        ),
                        child: Text(
                          member.role,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isAdmin ? const Color(0xFF7E22CE) : const Color(0xFF0052FF),
                          ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      // Small "View Card" Chevron Arrow
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Color(0xFFF1F5F9),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
