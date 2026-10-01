import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../backend/individual/previews/user_leads.dart';

class DashboardRecentLeads extends StatelessWidget {
  final VoidCallback? onSeeAllTap;

  const DashboardRecentLeads({
    super.key,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserLeadsService.instance,
      builder: (context, _) {
        final leads = UserLeadsService.instance.leads;
        final recentLeads = leads.take(3).toList();

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Leads",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAllTap ?? () => context.push('/portal/leads'),
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0066FF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentLeads.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                ),
                child: const Center(
                  child: Text(
                    "No recent leads captured yet",
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentLeads.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final lead = recentLeads[index];
                  final colors = _getAvatarColors(index);
                  return _buildLeadItem(
                    initial: lead.initials,
                    avatarBg: colors[0],
                    initialColor: colors[1],
                    name: lead.name,
                    company: lead.company,
                    source: lead.source,
                    time: _formatTime(lead.createdAt),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  List<Color> _getAvatarColors(int index) {
    final palette = [
      [const Color(0xFFE0F2FE), const Color(0xFF0284C7)],
      [const Color(0xFFF3E8FF), const Color(0xFF9333EA)],
      [const Color(0xFFDCFCE7), const Color(0xFF16A34A)],
    ];
    return palette[index % palette.length];
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  Widget _buildLeadItem({
    required String initial,
    required Color avatarBg,
    required Color initialColor,
    required String name,
    required String company,
    required String source,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: initialColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              source,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
