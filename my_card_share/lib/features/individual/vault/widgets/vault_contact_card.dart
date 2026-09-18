import 'package:flutter/material.dart';
import '../view_vault/view_vault_modal.dart';

class VaultContactCard extends StatelessWidget {
  final String name;
  final String role;
  final String company;
  final String dateAdded;
  final String tag; // 'OCR', 'Voice', 'Manual'
  final String? initials;
  final String? logoUrl;
  final VoidCallback? onTap;

  const VaultContactCard({
    super.key,
    required this.name,
    required this.role,
    required this.company,
    required this.dateAdded,
    required this.tag,
    this.initials,
    this.logoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ??
            () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ViewVaultModal(
                  name: name,
                  role: role,
                  company: company,
                  dateAdded: dateAdded,
                  tag: tag,
                  initials: initials,
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar or Logo Container
              _buildAvatar(),
              const SizedBox(width: 12),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      company,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Added $dateAdded",
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Column: Tag Badge
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildTagBadge(tag),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (initials != null) {
      final isPurple = initials == 'PS';
      final isGreen = initials == 'RJ';

      final bg = isPurple
          ? const Color(0xFFF3E8FF)
          : isGreen
              ? const Color(0xFFDCFCE7)
              : const Color(0xFFE0F2FE);

      final fg = isPurple
          ? const Color(0xFF9333EA)
          : isGreen
              ? const Color(0xFF16A34A)
              : const Color(0xFF0284C7);

      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      );
    }

    if (company.contains("TechNova")) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
        ),
      );
    }

    if (company.contains("Skyline")) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.diamond_rounded, color: Color(0xFFD97706), size: 22),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.apartment_rounded, color: Color(0xFF0284C7), size: 22),
      ),
    );
  }

  Widget _buildTagBadge(String tag) {
    Color bg = const Color(0xFFEFF6FF);
    Color fg = const Color(0xFF0284C7);

    if (tag.toLowerCase() == 'voice') {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF9333EA);
    } else if (tag.toLowerCase() == 'manual') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
