import 'package:flutter/material.dart';

class ProfileLiveCardPreview extends StatelessWidget {
  final String name;
  final String role;
  final String company;
  final String status;
  final int selectedTemplateIndex;
  final VoidCallback? onAvatarEditTap;
  final bool isPublished; // Added this

  const ProfileLiveCardPreview({
    super.key,
    required this.name,
    required this.role,
    required this.company,
    required this.status,
    this.selectedTemplateIndex = 0,
    this.onAvatarEditTap,
    this.isPublished = true, // Default to true
  });

  List<Color> _getGradientForTemplate(int index) {
    switch (index) {
      case 1:
        return const [Color(0xFF833AB4), Color(0xFFC13584)];
      case 2:
        return const [Color(0xFF0D9488), Color(0xFF2DD4BF)];
      case 3:
        return const [Color(0xFF0F172A), Color(0xFF334155)];
      case 4:
        return const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)];
      case 0:
      default:
        return const [Color(0xFF0052FF), Color(0xFF38BDF8)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientForTemplate(selectedTemplateIndex);
    final isLightTemplate = selectedTemplateIndex == 4;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner Image & Quote Header
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Good\nPeople\nBetter\nOpportunities",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isLightTemplate
                              ? const Color(0xFF475569)
                              : Colors.white.withValues(alpha: 0.85),
                          height: 1.2,
                        ),
                      ),
                      Text(
                        "Let's\nConnect",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: isLightTemplate
                              ? const Color(0xFF0052FF)
                              : Colors.white.withValues(alpha: 0.9),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlapping Avatar with Camera Edit Badge
              Positioned(
                bottom: -32,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80"),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onAvatarEditTap ??
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Upload photo clicked")),
                              );
                            },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0052FF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 38),

          // User Info & Status Tag
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0066FF),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPublished ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3), // Green-100 or Yellow-100
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isPublished ? const Color(0xFF22C55E) : const Color(0xFFEAB308), // Green-500 or Yellow-500
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isPublished ? status.toUpperCase() : "INACTIVE",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isPublished ? const Color(0xFF15803D) : const Color(0xFFA16207), // Green-700 or Yellow-700
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
