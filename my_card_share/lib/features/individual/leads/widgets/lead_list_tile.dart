import 'package:flutter/material.dart';

class LeadListTile extends StatelessWidget {
  final String initials;
  final String name;
  final String company;
  final String source; // 'via QR scan', 'via Voice', 'via Manual'
  final String date; // 'Sept 15'
  final String status; // 'New', 'Contacted', 'Qualified', 'Lost'
  final VoidCallback? onCallTap;
  final VoidCallback? onEmailTap;
  final VoidCallback? onMoreTap;

  const LeadListTile({
    super.key,
    required this.initials,
    required this.name,
    required this.company,
    required this.source,
    required this.date,
    required this.status,
    this.onCallTap,
    this.onEmailTap,
    this.onMoreTap,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Initials Avatar Circle
            _buildAvatar(),
            const SizedBox(width: 12),

            // Middle Info Column
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
                    company,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        source.contains("Voice")
                            ? Icons.mic_none_rounded
                            : source.contains("Manual")
                                ? Icons.person_outline_rounded
                                : Icons.qr_code_2_rounded,
                        size: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$source  •  $date",
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

            const SizedBox(width: 8),

            // Right Column: Status Badge & Quick Action Buttons (Call, Email, More)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusBadge(status),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onMoreTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Options for $name")),
                            );
                          },
                      child: const Icon(
                        Icons.more_vert_rounded,
                        color: Color(0xFF94A3B8),
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Call Button
                    GestureDetector(
                      onTap: onCallTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Calling $name...")),
                            );
                          },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: Color(0xFF0066FF),
                          size: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    // Email Button
                    GestureDetector(
                      onTap: onEmailTap ??
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Emailing $name...")),
                            );
                          },
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: Color(0xFF0066FF),
                          size: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    Color bg = const Color(0xFFE0F2FE);
    Color fg = const Color(0xFF0284C7);

    if (initials == 'PS') {
      bg = const Color(0xFFF3E8FF);
      fg = const Color(0xFF9333EA);
    } else if (initials == 'DK') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
    } else if (initials == 'SL') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    } else if (initials == 'RJ') {
      bg = const Color(0xFFFFEDD5);
      fg = const Color(0xFFEA580C);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFDCFCE7);
    Color fg = const Color(0xFF15803D);
    Color dot = const Color(0xFF22C55E);

    if (status.toLowerCase() == 'contacted') {
      bg = const Color(0xFFFEF9C3);
      fg = const Color(0xFFA16207);
      dot = const Color(0xFFEAB308);
    } else if (status.toLowerCase() == 'qualified') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
      dot = const Color(0xFF3B82F6);
    } else if (status.toLowerCase() == 'lost') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
      dot = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3.5),
          Text(
            status,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
