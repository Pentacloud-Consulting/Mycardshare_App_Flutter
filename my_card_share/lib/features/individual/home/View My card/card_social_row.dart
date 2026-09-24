import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';

class CardSocialRow extends StatelessWidget {
  final List<SocialLinkItem>? links;
  final VoidCallback? onLinkedInTap;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onWhatsAppTap;
  final VoidCallback? onWebsiteTap;
  final VoidCallback? onGitHubTap;

  const CardSocialRow({
    super.key,
    this.links,
    this.onLinkedInTap,
    this.onInstagramTap,
    this.onWhatsAppTap,
    this.onWebsiteTap,
    this.onGitHubTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeLinks = links ?? IndividualProfileStore.instance.activeProfile?.socialLinks ?? [];

    if (activeLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: activeLinks.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSocialIconButton(
              child: _buildPlatformIconWidget(item.platform),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${item.platform}: ${item.url}"),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlatformIconWidget(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('linkedin')) {
      return const FaIcon(FontAwesomeIcons.linkedinIn, color: Color(0xFF0A66C2), size: 20);
    } else if (p.contains('instagram')) {
      return ShaderMask(
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
          color: Colors.white,
          size: 22,
        ),
      );
    } else if (p.contains('whatsapp')) {
      return const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 22);
    } else if (p.contains('github')) {
      return const FaIcon(FontAwesomeIcons.github, color: Color(0xFF181717), size: 21);
    } else if (p.contains('twitter') || p.contains('x')) {
      return const FaIcon(FontAwesomeIcons.xTwitter, color: Color(0xFF000000), size: 20);
    } else if (p.contains('youtube')) {
      return const FaIcon(FontAwesomeIcons.youtube, color: Color(0xFFFF0000), size: 20);
    } else if (p.contains('portfolio')) {
      return const Icon(Icons.folder_shared_rounded, color: Color(0xFF8B5CF6), size: 22);
    } else {
      return const FaIcon(FontAwesomeIcons.globe, color: Color(0xFF0284C7), size: 20);
    }
  }

  Widget _buildSocialIconButton({
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
