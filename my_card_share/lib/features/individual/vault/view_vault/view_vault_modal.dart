import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ViewVaultModal extends StatelessWidget {
  final String name;
  final String role;
  final String company;
  final String dateAdded;
  final String tag;
  final String? initials;

  const ViewVaultModal({
    super.key,
    required this.name,
    required this.role,
    required this.company,
    required this.dateAdded,
    required this.tag,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Header Profile Info
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role,
                            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            company,
                            style: AppTextStyles.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTagBadge(tag),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.phone_rounded, "Call", const Color(0xFF10B981)),
                    _buildActionButton(Icons.message_rounded, "Message", const Color(0xFF3B82F6)),
                    _buildActionButton(Icons.email_rounded, "Email", const Color(0xFFF59E0B)),
                    _buildActionButton(Icons.share_rounded, "Share", const Color(0xFF6366F1)),
                  ],
                ),

                const SizedBox(height: 24),

                // Details List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.phone_outlined, "+1 (555) 0198-234"),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildDetailRow(Icons.email_outlined, "${name.split(' ').first.toLowerCase()}@${company.replaceAll(' ', '').toLowerCase()}.com"),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildDetailRow(Icons.language_rounded, "www.${company.replaceAll(' ', '').toLowerCase()}.com"),
                      const Divider(color: Color(0xFFF1F5F9), height: 24),
                      _buildDetailRow(Icons.location_on_outlined, "San Francisco, CA"),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Date Added Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      "Added to vault $dateAdded",
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(Icons.copy_rounded, size: 16, color: Color(0xFFCBD5E1)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
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
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials!,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      );
    }

    if (company.contains("TechNova")) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 30),
        ),
      );
    }

    if (company.contains("Skyline")) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.diamond_rounded, color: Color(0xFFD97706), size: 30),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(Icons.apartment_rounded, color: Color(0xFF0284C7), size: 30),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
