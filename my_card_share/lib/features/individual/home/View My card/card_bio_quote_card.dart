import 'package:flutter/material.dart';

/// Renders the BIO and EXPERIENCE input boxes matching the Web Card exactly (Image 3).
class CardBioQuoteCard extends StatelessWidget {
  final String bio;
  final String? experience;

  const CardBioQuoteCard({
    super.key,
    this.bio = "Passionate about creating meaningful connections and building brands that make a difference.",
    this.experience,
  });

  @override
  Widget build(BuildContext context) {
    final cleanBio = bio.trim();
    final cleanExp = (experience ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. BIO Box ────────────────────────────────────────────────────────
        if (cleanBio.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              "BIO",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              cleanBio,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF475569),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],

        // ── 2. EXPERIENCE Box ─────────────────────────────────────────────────
        if (cleanExp.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              "EXPERIENCE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cleanExp.split('\n').map((line) {
                final trimmed = line.trim();
                if (trimmed.isEmpty) return const SizedBox.shrink();
                final cleanLine = trimmed.startsWith('•') || trimmed.startsWith('-')
                    ? trimmed.substring(1).trim()
                    : trimmed;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 7, right: 10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          cleanLine,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
