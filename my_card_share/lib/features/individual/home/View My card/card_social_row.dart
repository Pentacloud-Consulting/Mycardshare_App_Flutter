import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardSocialRow extends StatelessWidget {
  final VoidCallback? onLinkedInTap;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onWebsiteTap;
  final VoidCallback? onGitHubTap;

  const CardSocialRow({
    super.key,
    this.onLinkedInTap,
    this.onInstagramTap,
    this.onWhatsAppTap,
    this.onWebsiteTap,
    this.onGitHubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // LinkedIn - Official Blue #0A66C2
        _buildSocialIconButton(
          iconColor: const Color(0xFF0A66C2),
          child: const FaIcon(
            FontAwesomeIcons.linkedinIn,
            color: Color(0xFF0A66C2),
            size: 20,
          ),
          onTap: onLinkedInTap ?? () {},
        ),

        // Instagram - Authentic Multi-stop Sunset Gradient (ShaderMask)
        _buildSocialIconButton(
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color(0xFF405DE6),
                  Color(0xFF833AB4),
                  Color(0xFFC13584),
                  Color(0xFFE1306C),
                  Color(0xFFFD1D1D),
                  Color(0xFFF77737),
                  Color(0xFFFCCC63),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ).createShader(bounds);
            },
            child: const FaIcon(
              FontAwesomeIcons.instagram,
              color: Colors.white, // Mask uses white base to apply shader gradient
              size: 22,
            ),
          ),
          onTap: onInstagramTap ?? () {},
        ),

        // WhatsApp - Official Green #25D366
        _buildSocialIconButton(
          iconColor: const Color(0xFF25D366),
          child: const FaIcon(
            FontAwesomeIcons.whatsapp,
            color: Color(0xFF25D366),
            size: 22,
          ),
          onTap: onWhatsAppTap ?? () {},
        ),

        // Website - Ocean Blue #0284C7
        _buildSocialIconButton(
          iconColor: const Color(0xFF0284C7),
          child: const FaIcon(
            FontAwesomeIcons.globe,
            color: Color(0xFF0284C7),
            size: 20,
          ),
          onTap: onWebsiteTap ?? () {},
        ),

        // GitHub - Authentic Dark Charcoal #181717
        _buildSocialIconButton(
          iconColor: const Color(0xFF181717),
          child: const FaIcon(
            FontAwesomeIcons.github,
            color: Color(0xFF181717),
            size: 21,
          ),
          onTap: onGitHubTap ?? () {},
        ),
      ],
    );
  }

  Widget _buildSocialIconButton({
    Color? iconColor,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}
