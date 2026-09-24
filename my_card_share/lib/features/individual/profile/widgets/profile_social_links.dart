import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../backend/individual/profile/individual_profile_store.dart';

class ProfileSocialLinks extends StatelessWidget {
  final List<SocialLinkItem>? links;
  final VoidCallback? onManageTap;
  final VoidCallback? onAddMoreTap;
  final Function(SocialLinkItem)? onItemTap;
  final Function(int)? onDeleteItem;
  final bool isEditable;

  const ProfileSocialLinks({
    super.key,
    this.links,
    this.onManageTap,
    this.onAddMoreTap,
    this.onItemTap,
    this.onDeleteItem,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeLinks = links ?? IndividualProfileStore.instance.activeProfile?.socialLinks ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Social Links",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            if (onManageTap != null)
              GestureDetector(
                onTap: onManageTap,
                child: const Text(
                  "Manage",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0052FF),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (activeLinks.isEmpty)
          GestureDetector(
            onTap: onAddMoreTap ?? onManageTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline_rounded, color: Color(0xFF0052FF), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Add Your Social Links",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...activeLinks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildSocialTile(
                      context: context,
                      item: item,
                      onTap: () {
                        if (onItemTap != null) {
                          onItemTap!(item);
                        } else {
                          _handleTileTap(context, item);
                        }
                      },
                      onDelete: isEditable && onDeleteItem != null
                          ? () => onDeleteItem!(index)
                          : null,
                    ),
                  );
                }),

                if (onAddMoreTap != null)
                  GestureDetector(
                    onTap: onAddMoreTap,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
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
                          Icon(Icons.add_rounded, color: Color(0xFF94A3B8), size: 22),
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

  void _handleTileTap(BuildContext context, SocialLinkItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.platform}: ${item.url}"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSocialTile({
    required BuildContext context,
    required SocialLinkItem item,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    final platform = item.platform;
    final info = _getPlatformStyle(platform);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: info.backgroundColor,
                      gradient: info.gradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: info.icon),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    platform,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _PlatformStyle _getPlatformStyle(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('linkedin')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.linkedinIn, color: Colors.white, size: 16),
        backgroundColor: const Color(0xFF0A66C2),
      );
    } else if (p.contains('instagram')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white, size: 16),
        gradient: const LinearGradient(
          colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFF77737)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else if (p.contains('whatsapp')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 16),
        backgroundColor: const Color(0xFF25D366),
      );
    } else if (p.contains('github')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.github, color: Colors.white, size: 16),
        backgroundColor: const Color(0xFF181717),
      );
    } else if (p.contains('twitter') || p.contains('x')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white, size: 15),
        backgroundColor: const Color(0xFF000000),
      );
    } else if (p.contains('youtube')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.youtube, color: Colors.white, size: 15),
        backgroundColor: const Color(0xFFFF0000),
      );
    } else if (p.contains('facebook')) {
      return _PlatformStyle(
        icon: const FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 15),
        backgroundColor: const Color(0xFF1877F2),
      );
    } else if (p.contains('portfolio')) {
      return _PlatformStyle(
        icon: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 16),
        backgroundColor: const Color(0xFF8B5CF6),
      );
    } else {
      return _PlatformStyle(
        icon: const Icon(Icons.language_rounded, color: Colors.white, size: 16),
        backgroundColor: const Color(0xFF0052FF),
      );
    }
  }
}

class _PlatformStyle {
  final Widget icon;
  final Color? backgroundColor;
  final Gradient? gradient;

  _PlatformStyle({
    required this.icon,
    this.backgroundColor,
    this.gradient,
  });
}

