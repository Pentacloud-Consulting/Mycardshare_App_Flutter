import 'package:flutter/material.dart';

class AnalyticsAiEngineSplit extends StatelessWidget {
  const AnalyticsAiEngineSplit({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "AI Engine Usage Split",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF8B5CF6), size: 18),
            ],
          ),

          const SizedBox(height: 18),

          // 1. Gemini OCR 68%
          _buildEngineBar(
            name: "Gemini OCR",
            percentageText: "68%",
            ratio: 0.68,
            color: const Color(0xFF0052FF),
            icon: Icons.document_scanner_rounded,
          ),

          const SizedBox(height: 14),

          // 2. Gemini Voice AI 24%
          _buildEngineBar(
            name: "Gemini Voice AI",
            percentageText: "24%",
            ratio: 0.24,
            color: const Color(0xFF8B5CF6),
            icon: Icons.mic_rounded,
          ),

          const SizedBox(height: 14),

          // 3. HuggingFace Fallback 8%
          _buildEngineBar(
            name: "HuggingFace Fallback",
            percentageText: "8%",
            ratio: 0.08,
            color: const Color(0xFF64748B),
            icon: Icons.alt_route_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildEngineBar({
    required String name,
    required String percentageText,
    required double ratio,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              percentageText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
