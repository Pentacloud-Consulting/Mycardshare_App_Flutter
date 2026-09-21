import 'package:flutter/material.dart';

class BrandLivePreview extends StatelessWidget {
  final Color selectedColor;
  final String selectedTemplateId;

  const BrandLivePreview({
    super.key,
    required this.selectedColor,
    required this.selectedTemplateId,
  });

  @override
  Widget build(BuildContext context) {
    Color cardBgPrimary = selectedColor;
    Color cardBgSecondary = selectedColor.withValues(alpha: 0.7);
    Color cardTextColor = Colors.white;

    if (selectedTemplateId == "minimal_dark") {
      cardBgPrimary = const Color(0xFF0F172A);
      cardBgSecondary = const Color(0xFF1E293B);
      cardTextColor = Colors.white;
    } else if (selectedTemplateId == "corporate_clean") {
      cardBgPrimary = Colors.white;
      cardBgSecondary = const Color(0xFFF1F5F9);
      cardTextColor = const Color(0xFF0F172A);
    } else if (selectedTemplateId == "bold_gradient") {
      cardBgPrimary = const Color(0xFF7C3AED);
      cardBgSecondary = const Color(0xFFEC4899);
      cardTextColor = Colors.white;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "LIVE PREVIEW",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Real-time",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Mini Employee Card Mockup
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [cardBgPrimary, cardBgSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: cardTextColor.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardBgPrimary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with Company Watermark Badge
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: cardTextColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person_rounded,
                        color: cardTextColor,
                        size: 26,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alex Morgan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: cardTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Senior Vice President",
                        style: TextStyle(
                          fontSize: 12,
                          color: cardTextColor.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 12,
                            color: cardTextColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Acme Realty Group",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: cardTextColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.qr_code_2_rounded,
                  color: cardTextColor.withValues(alpha: 0.85),
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
