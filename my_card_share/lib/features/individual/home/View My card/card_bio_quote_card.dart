import 'package:flutter/material.dart';

class CardBioQuoteCard extends StatelessWidget {
  final String bio;

  const CardBioQuoteCard({
    super.key,
    this.bio = "Passionate about creating meaningful connections and building brands that make a difference. Always open to new opportunities and collaborations.",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: Color(0xFF93C5FD),
            size: 28,
          ),
          const SizedBox(height: 2),
          Text(
            bio,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
