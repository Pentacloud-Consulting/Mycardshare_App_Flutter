import 'package:flutter/material.dart';

class AiEngineKeysSection extends StatelessWidget {
  final VoidCallback? onEditGemini;
  final VoidCallback? onEditHuggingFace;
  final VoidCallback? onFirebaseConfig;

  const AiEngineKeysSection({
    super.key,
    this.onEditGemini,
    this.onEditHuggingFace,
    this.onFirebaseConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Text(
          "AI ENGINE KEYS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),

        // Grouped List Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Row 1: Gemini API Key
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Gemini API Key",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "sk-••••••••7f2a",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: const Color(0xFF64748B).withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onEditGemini,
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Row 2: Firebase Admin Key
              InkWell(
                onTap: onFirebaseConfig,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFEA580C),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Firebase Admin Key",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const Text(
                        "Configured",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // Row 3: HuggingFace API Key
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF4FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.memory_rounded,
                        color: Color(0xFFC026D3),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "HuggingFace API Key",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "hf_••••••••9c1d",
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: const Color(0xFF64748B).withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onEditHuggingFace,
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
