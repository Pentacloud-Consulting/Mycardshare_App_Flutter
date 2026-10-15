import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../backend/enterprise/request/request_fetch.dart';
import '../../../../backend/employee_join/email_send_request.dart';

/// Screen in `lib/features/enterprise/settings/requests/enterprise_requests_screen.dart`
/// Displays and manages all real incoming "Join Enterprise Requests" submitted by employees.
class EnterpriseRequestsScreen extends StatefulWidget {
  const EnterpriseRequestsScreen({super.key});

  @override
  State<EnterpriseRequestsScreen> createState() => _EnterpriseRequestsScreenState();
}

class _EnterpriseRequestsScreenState extends State<EnterpriseRequestsScreen> {
  String _filter = 'all'; // 'all', 'pending', 'approved', 'rejected'

  @override
  void initState() {
    super.initState();
    EnterpriseRequestFetchService.instance.fetchJoinRequests();
  }

  void _handleApprove(EnterpriseJoinRequestModel req) async {
    final success = await EnterpriseRequestFetchService.instance.approveJoinRequest(request: req);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text("${req.applicantName} approved and added to workspace!"),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Failed to approve request. Please try again."),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleReject(EnterpriseJoinRequestModel req) async {
    final success = await EnterpriseRequestFetchService.instance.rejectJoinRequest(request: req);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request from ${req.applicantName} declined."),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: ListenableBuilder(
        listenable: EnterpriseRequestFetchService.instance,
        builder: (context, _) {
          return StreamBuilder<List<EnterpriseJoinRequestModel>>(
            stream: EnterpriseRequestFetchService.instance.streamJoinRequests(uid),
            builder: (context, snapshot) {
              final streamData = snapshot.data ?? [];
              final localData = EnterpriseRequestFetchService.instance.requests;
              // Merge unique by ID
              final Map<String, EnterpriseJoinRequestModel> mergedMap = {};
              for (final r in localData) {
                mergedMap[r.id] = r;
              }
              for (final r in streamData) {
                mergedMap[r.id] = r;
              }
              final all = mergedMap.values.toList();
              all.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              final filtered = all.where((r) {
                if (_filter == 'pending') return r.status == 'pending';
                if (_filter == 'approved') return r.status == 'approved';
                if (_filter == 'rejected') return r.status == 'rejected';
                return true;
              }).toList();

          return Column(
            children: [
              // Filter chips row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All (${all.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('pending', 'Pending (${all.where((r) => r.status == 'pending').length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('approved', 'Approved'),
                    const SizedBox(width: 8),
                    _buildFilterChip('rejected', 'Declined'),
                  ],
                ),
              ),

              // Request list
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final req = filtered[index];
                          return _buildRequestCard(req);
                        },
                      ),
              ),
            ],
          );
        },
      );
    },
  ),
);
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _filter == id;
    return GestureDetector(
      onTap: () => setState(() => _filter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0052FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0052FF) : const Color(0xFFCBD5E1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(EnterpriseJoinRequestModel req) {
    Color statusBg = const Color(0xFFFEF3C7);
    Color statusTextColor = const Color(0xFFD97706);
    String statusLabel = "Pending Review";

    if (req.status == 'approved') {
      statusBg = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF15803D);
      statusLabel = "Approved";
    } else if (req.status == 'rejected') {
      statusBg = const Color(0xFFFEE2E2);
      statusTextColor = const Color(0xFFDC2626);
      statusLabel = "Declined";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  req.applicantName.isNotEmpty ? req.applicantName[0].toUpperCase() : 'E',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.applicantName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      req.applicantEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),

          if (req.status == 'pending') ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _handleReject(req),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text("Decline", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _handleApprove(req),
                  icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  label: const Text("Approve & Add", style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                size: 36,
                color: Color(0xFF0052FF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Join Requests",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Prospective employees who submit join requests with your enterprise email will appear here for verification.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
