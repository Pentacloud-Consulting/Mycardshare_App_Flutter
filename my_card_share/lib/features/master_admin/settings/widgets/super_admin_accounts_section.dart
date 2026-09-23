import 'dart:ui';
import 'package:flutter/material.dart';

class AdminAccountItem {
  final String initials;
  final String name;
  final String email;
  final bool isPrimary;

  const AdminAccountItem({
    required this.initials,
    required this.name,
    required this.email,
    this.isPrimary = false,
  });
}

class SuperAdminAccountsSection extends StatelessWidget {
  final List<AdminAccountItem>? adminAccounts;
  final Function(AdminAccountItem)? onRemoveAccount;
  final VoidCallback? onAddSuperAdmin;

  const SuperAdminAccountsSection({
    super.key,
    this.adminAccounts,
    this.onRemoveAccount,
    this.onAddSuperAdmin,
  });

  static const List<AdminAccountItem> _defaultAdmins = [
    AdminAccountItem(
      initials: "MA",
      name: "System Master Admin",
      email: "admin@mycardshare.com",
      isPrimary: true,
    ),
    AdminAccountItem(
      initials: "AR",
      name: "Alex Rivera",
      email: "alex.r@mycardshare.com",
    ),
    AdminAccountItem(
      initials: "SC",
      name: "Sarah Chen",
      email: "sarah.c@mycardshare.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = adminAccounts ?? _defaultAdmins;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Text(
          "SUPER ADMIN ACCOUNTS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        // Accounts Container Card
        Container(
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
          child: Column(
            children: [
              // List of Admin Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, index) {
                  final admin = list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Initials Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF334155)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              admin.initials,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Name & Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      admin.name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Purple Super Admin Pill Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      "SUPER ADMIN",
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF7E22CE),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                admin.email,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Remove Link
                        GestureDetector(
                          onTap: () => onRemoveAccount?.call(admin),
                          child: const Text(
                            "Remove",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Dashed-border "+ Add Super Admin" button inside card
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: InkWell(
                  onTap: onAddSuperAdmin,
                  borderRadius: BorderRadius.circular(12),
                  child: CustomPaint(
                    painter: _DashedRectPainter(
                      color: const Color(0xFF60A5FA),
                      strokeWidth: 1.2,
                      gap: 4.0,
                      radius: 12.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Add Super Admin",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.gap = 4.0,
    this.radius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double length = draw ? 5.0 : gap;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
