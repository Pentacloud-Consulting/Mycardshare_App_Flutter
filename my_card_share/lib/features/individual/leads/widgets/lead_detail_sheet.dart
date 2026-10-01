import 'package:flutter/material.dart';
import '../../../../backend/individual/lead/active_lead.dart';

/// Modal bottom sheet to view full lead details (matching Image 3 Vault detail view styling).
class LeadDetailSheet extends StatelessWidget {
  final LeadData lead;

  const LeadDetailSheet({
    super.key,
    required this.lead,
  });

  static void show(BuildContext context, LeadData lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LeadDetailSheet(lead: lead),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Top Profile Header (Avatar + Name + Tag)
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3E8FF),
                  ),
                  child: Center(
                    child: Text(
                      lead.initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9333EA),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lead.company,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lead.source.replaceAll('via ', ''),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9333EA),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Quick Action Buttons (Call, Message, Email, Share)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(Icons.phone_rounded, "Call", const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
                _buildQuickActionButton(Icons.message_rounded, "Message", const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                _buildQuickActionButton(Icons.email_rounded, "Email", const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                _buildQuickActionButton(Icons.share_rounded, "Share", const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
              ],
            ),

            const SizedBox(height: 22),

            // Detail Card Box (Image 3 style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.phone_outlined, lead.phone.isNotEmpty ? lead.phone : "+1 (555) 0198-234"),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(Icons.mail_outline_rounded, lead.email.isNotEmpty ? lead.email : "contact@lead.com"),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(Icons.language_rounded, "www.${lead.company.replaceAll(' ', '').toLowerCase()}.com"),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(Icons.location_on_outlined, "San Francisco, CA"),
                  if (lead.notes.isNotEmpty) ...[
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(Icons.chat_bubble_outline_rounded, lead.notes),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Date Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  "Added to leads ${lead.createdAt.day} ${_getMonthName(lead.createdAt.month)}",
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String label, Color bg, Color fg) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: fg, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        const Icon(Icons.copy_rounded, size: 16, color: Color(0xFFCBD5E1)),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }
}
