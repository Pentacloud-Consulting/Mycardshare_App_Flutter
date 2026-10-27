import 'package:flutter/material.dart';
import '../../../../backend/individual/lead/active_lead.dart';
import '../../../../backend/individual/lead/lead_action_helper.dart';
import 'edit_lead.dart';

/// Modal bottom sheet to view full lead details (matching Image 3 Vault detail view styling) with Edit support.
class LeadDetailSheet extends StatefulWidget {
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
  State<LeadDetailSheet> createState() => _LeadDetailSheetState();
}

class _LeadDetailSheetState extends State<LeadDetailSheet> {
  late LeadData _currentLead;

  @override
  void initState() {
    super.initState();
    _currentLead = widget.lead;
  }

  @override
  Widget build(BuildContext context) {
    final lead = _currentLead;

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

            // Top Profile Header (Avatar + Name + Tag + Edit Button)
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3E8FF),
                  ),
                  child: Center(
                    child: Text(
                      lead.initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9333EA),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
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
                // Edit Lead Action Button
                InkWell(
                  onTap: () async {
                    final updated = await EditLeadSheet.show(
                      context,
                      lead: lead,
                      targetUid: lead.targetUid,
                      onLeadUpdated: (newLead) {
                        if (mounted) setState(() => _currentLead = newLead);
                      },
                    );
                    if (updated is LeadData && mounted) {
                      setState(() => _currentLead = updated);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0052FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF0052FF).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_rounded, size: 14, color: Color(0xFF0052FF)),
                        SizedBox(width: 4),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0052FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
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
                _buildQuickActionButton(
                  icon: Icons.phone_rounded,
                  label: "Call",
                  bg: const Color(0xFFDCFCE7),
                  fg: const Color(0xFF16A34A),
                  onTap: () => LeadActionHelper.callLead(context, name: lead.name, phone: lead.phone),
                ),
                _buildQuickActionButton(
                  icon: Icons.message_rounded,
                  label: "Message",
                  bg: const Color(0xFFEFF6FF),
                  fg: const Color(0xFF2563EB),
                  onTap: () => LeadActionHelper.messageLead(context, name: lead.name, phone: lead.phone),
                ),
                _buildQuickActionButton(
                  icon: Icons.email_rounded,
                  label: "Email",
                  bg: const Color(0xFFFEF3C7),
                  fg: const Color(0xFFD97706),
                  onTap: () => LeadActionHelper.emailLead(context, name: lead.name, email: lead.email),
                ),
                _buildQuickActionButton(
                  icon: Icons.share_rounded,
                  label: "Share",
                  bg: const Color(0xFFF3E8FF),
                  fg: const Color(0xFF9333EA),
                  onTap: () => LeadActionHelper.shareLead(context, lead),
                ),
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
                  _buildDetailRow(
                    icon: Icons.phone_outlined,
                    value: lead.phone.trim().isNotEmpty ? lead.phone.trim() : "Not provided",
                    label: "phone number",
                    onTap: lead.phone.trim().isNotEmpty && lead.phone.trim().toLowerCase() != "not provided"
                        ? () => LeadActionHelper.callLead(context, name: lead.name, phone: lead.phone)
                        : null,
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.mail_outline_rounded,
                    value: lead.email.trim().isNotEmpty ? lead.email.trim() : "Not provided",
                    label: "email address",
                    onTap: lead.email.trim().isNotEmpty && lead.email.trim().toLowerCase() != "not provided"
                        ? () => LeadActionHelper.emailLead(context, name: lead.name, email: lead.email)
                        : null,
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.language_rounded,
                    value: lead.website.trim().isNotEmpty
                        ? lead.website.trim()
                        : "www.${lead.company.trim().replaceAll(' ', '').toLowerCase()}.com",
                    label: "website",
                    onTap: () {
                      final site = lead.website.trim().isNotEmpty
                          ? lead.website.trim()
                          : "www.${lead.company.trim().replaceAll(' ', '').toLowerCase()}.com";
                      LeadActionHelper.openUrl(context, site);
                    },
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    value: lead.location.trim().isNotEmpty ? lead.location.trim() : "San Francisco, CA",
                    label: "location",
                    onTap: () {
                      final loc = lead.location.trim().isNotEmpty ? lead.location.trim() : "San Francisco, CA";
                      LeadActionHelper.openUrl(context, "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(loc)}");
                    },
                  ),
                  if (lead.notes.trim().isNotEmpty) ...[
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildDetailRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      value: lead.notes.trim(),
                      label: "notes",
                      onTap: null,
                    ),
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
                  _formatDetailDate(lead.createdAt),
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

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: fg.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
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
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => LeadActionHelper.copyToClipboard(context, value, label),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF94A3B8)),
              splashRadius: 18,
              onPressed: () => LeadActionHelper.copyToClipboard(context, value, label),
              tooltip: "Copy $label",
            ),
          ],
        ),
      ),
    );
  }

  String _formatDetailDate(DateTime dt) {
    final localDt = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final leadDate = DateTime(localDt.year, localDt.month, localDt.day);

    if (leadDate == today) {
      return "Added to leads Today";
    }
    if (leadDate == today.subtract(const Duration(days: 1))) {
      return "Added to leads Yesterday";
    }
    return "Added to leads ${localDt.day} ${_getMonthName(localDt.month)}";
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }
}


