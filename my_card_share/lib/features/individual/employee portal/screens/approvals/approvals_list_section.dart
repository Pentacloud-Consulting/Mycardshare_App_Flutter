import 'package:flutter/material.dart';

class ApprovalRequestItem {
  final String id;
  final String type;
  final String submittedTime;
  final String fromValue;
  final String toValue;
  final String status; // Pending, Approved, Rejected
  final String? adminNote;

  const ApprovalRequestItem({
    required this.id,
    required this.type,
    required this.submittedTime,
    required this.fromValue,
    required this.toValue,
    required this.status,
    this.adminNote,
  });
}

class ApprovalsListSection extends StatelessWidget {
  final List<ApprovalRequestItem> requests;
  final ValueChanged<ApprovalRequestItem>? onItemTap;

  const ApprovalsListSection({
    super.key,
    required this.requests,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
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
            Icon(Icons.assignment_turned_in_rounded, size: 44, color: Color(0xFF94A3B8)),
            SizedBox(height: 10),
            Text(
              "No Change Requests",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            SizedBox(height: 4),
            Text(
              "Submit a new request to update locked corporate fields.",
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: requests.map((item) {
        final isPending = item.status == "Pending";
        final isApproved = item.status == "Approved";

        Color accentBorderColor;
        Color tagBgColor;
        Color tagTextColor;
        IconData tagIcon;

        if (isPending) {
          accentBorderColor = const Color(0xFFFDE68A);
          tagBgColor = const Color(0xFFFFFBEB);
          tagTextColor = const Color(0xFFD97706);
          tagIcon = Icons.access_time_rounded;
        } else if (isApproved) {
          accentBorderColor = const Color(0xFFA7F3D0);
          tagBgColor = const Color(0xFFECFDF5);
          tagTextColor = const Color(0xFF059669);
          tagIcon = Icons.check_circle_rounded;
        } else {
          accentBorderColor = const Color(0xFFFECACA);
          tagBgColor = const Color(0xFFFEF2F2);
          tagTextColor = const Color(0xFFDC2626);
          tagIcon = Icons.cancel_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPending
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isPending
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                    : const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Left Amber Indicator Stripe for Pending Requests
                if (isPending)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 4.5,
                    child: Container(
                      color: const Color(0xFFF59E0B),
                    ),
                  ),

                InkWell(
                  onTap: () => onItemTap?.call(item),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isPending ? 18.0 : 16.0,
                      top: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Icon Badge (Pencil) + Request Type & Time + Colored Status Pill
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF0052FF),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.type,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Submitted ${item.submittedTime}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Status Tag Pill
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: tagBgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: accentBorderColor, width: 1.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(tagIcon, size: 13, color: tagTextColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: tagTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Middle: Light Gray "Before/After" Comparison Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFD),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              // Before Text (Strikethrough Gray)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "From",
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      item.fromValue,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF64748B),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Color(0xFF94A3B8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 16,
                                ),
                              ),
                              // After Text (Bold Blue or Green/Red)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "To",
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      item.toValue,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isPending
                                            ? const Color(0xFF0052FF)
                                            : isApproved
                                                ? const Color(0xFF059669)
                                                : const Color(0xFFDC2626),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom of Card: Caption or Admin Note
                        if (isPending) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Awaiting admin review",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ] else if (item.adminNote != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            "Admin Note: ${item.adminNote}",
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
