import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileSocialLinks extends StatelessWidget {
  final VoidCallback? onManageTap;
  final VoidCallback? onAddMoreTap;

  const ProfileSocialLinks({
    super.key,
    this.onManageTap,
    this.onAddMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Social Links",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: onManageTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Manage social links opened")),
                    );
                  },
              child: const Text(
                "Manage",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal Row of Social Link Buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // LinkedIn
              _buildSocialTile(
                label: "LinkedIn",
                child: const FaIcon(
                  FontAwesomeIcons.linkedinIn,
                  color: Colors.white,
                  size: 16,
                ),
                backgroundColor: const Color(0xFF0A66C2),
              ),
              const SizedBox(width: 10),

              // Instagram
              _buildSocialTile(
                label: "Instagram",
                child: const FaIcon(
                  FontAwesomeIcons.instagram,
                  color: Colors.white,
                  size: 16,
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF77737)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              const SizedBox(width: 10),

              // WhatsApp
              _buildSocialTile(
                label: "WhatsApp",
                child: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 16,
                ),
                backgroundColor: const Color(0xFF25D366),
              ),
              const SizedBox(width: 10),

              // GitHub
              _buildSocialTile(
                label: "GitHub",
                child: const FaIcon(
                  FontAwesomeIcons.github,
                  color: Colors.white,
                  size: 16,
                ),
                backgroundColor: const Color(0xFF181717),
              ),
              const SizedBox(width: 10),

              // Add More
              GestureDetector(
                onTap: onAddMoreTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Add social link opened")),
                      );
                    },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_rounded, color: Color(0xFF94A3B8), size: 20),
                      SizedBox(height: 2),
                      Text(
                        "Add More",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialTile({
    required String label,
    required Widget child,
    Color? backgroundColor,
    Gradient? gradient,
  }) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: Center(child: child),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0052FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_rounded, color: Colors.white, size: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
