import 'package:flutter/material.dart';

class WorkspaceItem {
  final String domain;
  final String companyName;
  final bool isActive;

  const WorkspaceItem({
    required this.domain,
    required this.companyName,
    required this.isActive,
  });
}

class WorkspaceListSection extends StatelessWidget {
  final List<WorkspaceItem>? workspaces;
  final Function(WorkspaceItem)? onWorkspaceTap;
  final Function(WorkspaceItem)? onMenuTap;

  const WorkspaceListSection({
    super.key,
    this.workspaces,
    this.onWorkspaceTap,
    this.onMenuTap,
  });

  static const List<WorkspaceItem> defaultWorkspaces = [
    WorkspaceItem(
      domain: "acme-realty.mycardshare.com",
      companyName: "Acme Realty Group",
      isActive: true,
    ),
    WorkspaceItem(
      domain: "zenith-tech.mycardshare.com",
      companyName: "Zenith Technologies",
      isActive: false,
    ),
    WorkspaceItem(
      domain: "nova-consulting.mycardshare.com",
      companyName: "Nova Consulting",
      isActive: true,
    ),
    WorkspaceItem(
      domain: "pixel-studio.mycardshare.com",
      companyName: "Pixel Studio",
      isActive: false,
    ),
    WorkspaceItem(
      domain: "orion-trading.mycardshare.com",
      companyName: "Orion Trading Co.",
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = workspaces ?? defaultWorkspaces;

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
              Icons.search_off_rounded,
              size: 36,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 10),
            Text(
              "No workspaces found",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Try searching with a different domain or company name.",
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
            onTap: () => onWorkspaceTap?.call(item),
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(16) : Radius.zero,
              bottom: index == list.length - 1 ? const Radius.circular(16) : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Building Icon Badge
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Domain + Company Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.domain,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.companyName,
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

                  // Status Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isActive
                          ? const Color(0xFFDCFCE7) // Light green
                          : const Color(0xFFF1F5F9), // Light gray
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.isActive ? "Active" : "Unassigned",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.isActive
                            ? const Color(0xFF15803D) // Dark green
                            : const Color(0xFF64748B), // Dark gray
                      ),
                    ),
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
}
