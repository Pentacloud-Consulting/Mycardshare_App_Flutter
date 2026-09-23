import 'package:flutter/material.dart';

class IndividualUserItem {
  final String id;
  final String initials;
  final String name;
  final String email;
  final String plan; // "Free", "Pro", "Deactivated"
  final String joinedDate;
  final bool isDeactivated;

  const IndividualUserItem({
    required this.id,
    required this.initials,
    required this.name,
    required this.email,
    required this.plan,
    required this.joinedDate,
    this.isDeactivated = false,
  });
}

class IndividualsListSection extends StatelessWidget {
  final List<IndividualUserItem>? users;
  final Function(IndividualUserItem)? onUserTap;
  final Function(IndividualUserItem)? onMenuTap;

  const IndividualsListSection({
    super.key,
    this.users,
    this.onUserTap,
    this.onMenuTap,
  });

  static const List<IndividualUserItem> defaultUsers = [
    IndividualUserItem(
      id: "1",
      initials: "AJ",
      name: "Alex Johnson",
      email: "alex.johnson@gmail.com",
      plan: "Pro",
      joinedDate: "Joined Mar 2026",
    ),
    IndividualUserItem(
      id: "2",
      initials: "MG",
      name: "Maria Garcia",
      email: "maria.g@outlook.com",
      plan: "Free",
      joinedDate: "Joined Feb 2026",
    ),
    IndividualUserItem(
      id: "3",
      initials: "DS",
      name: "David Smith",
      email: "david.smith@techcorp.io",
      plan: "Pro",
      joinedDate: "Joined Jan 2026",
    ),
    IndividualUserItem(
      id: "4",
      initials: "ER",
      name: "Elena Rostova",
      email: "elena.r@designstudio.co",
      plan: "Deactivated",
      joinedDate: "Joined Dec 2025",
      isDeactivated: true,
    ),
    IndividualUserItem(
      id: "5",
      initials: "LW",
      name: "Liam Wilson",
      email: "liam.w@freelance.dev",
      plan: "Free",
      joinedDate: "Joined Nov 2025",
    ),
    IndividualUserItem(
      id: "6",
      initials: "SP",
      name: "Sophia Patel",
      email: "sophia.patel@innovate.org",
      plan: "Pro",
      joinedDate: "Joined Oct 2025",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = users ?? defaultUsers;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 36,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 10),
            Text(
              "No users found",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try adjusting your search query or filter selection.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF1F5F9),
        ),
        itemBuilder: (context, index) {
          final item = list[index];
          return InkWell(
            onTap: () => onUserTap?.call(item),
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(16) : Radius.zero,
              bottom: index == list.length - 1 ? const Radius.circular(16) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Circular Initials Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: item.isDeactivated
                            ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                            : [const Color(0xFF0F172A), const Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & Email Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: item.isDeactivated
                                ? const Color(0xFF64748B)
                                : const Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.email,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right Side: Plan Tag + Joined Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPlanTag(item.plan),
                      const SizedBox(height: 4),
                      Text(
                        item.joinedDate,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),

                  // 3-Dot Overflow Menu Icon
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    onPressed: () => onMenuTap?.call(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanTag(String plan) {
    if (plan == "Pro") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF), // Blue background
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 1.0),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              size: 12,
              color: Color(0xFF2563EB),
            ),
            SizedBox(width: 3),
            Text(
              "Pro",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      );
    } else if (plan == "Deactivated") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2), // Red background
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Deactivated",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDC2626),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9), // Gray background
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Free",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }
  }
}
