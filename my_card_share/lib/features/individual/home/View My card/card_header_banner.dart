import 'dart:io';
import 'package:flutter/material.dart';

class CardHeaderBanner extends StatelessWidget {
  final String name;
  final String role;
  final String company;
  final String status;
  final int selectedTemplateIndex;
  final String? avatarAsset;
  final String? avatarUrl;
  final String? bannerAsset;
  final String? bannerUrl;

  const CardHeaderBanner({
    super.key,
    required this.name,
    required this.role,
    required this.company,
    this.status = 'ACTIVELY NETWORKING',
    this.selectedTemplateIndex = 0,
    this.avatarAsset,
    this.avatarUrl,
    this.bannerAsset,
    this.bannerUrl,
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

  Widget _buildBannerImage() {
    final photo = bannerUrl ?? bannerAsset;
    if (photo != null && photo.isNotEmpty) {
      if (photo.startsWith('http')) {
        return Image.network(photo, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const SizedBox.shrink());
      }
      try {
        final file = File(photo);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        }
      } catch (_) {}
      return Image.asset(photo, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => const SizedBox.shrink());
    }
    return const SizedBox.shrink();
  }

  Widget _buildAvatarImage() {
    final photo = avatarUrl ?? avatarAsset;
    if (photo != null && photo.isNotEmpty) {
      if (photo.startsWith('http')) {
        return Image.network(photo, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => _buildAvatarFallback());
      }
      try {
        final file = File(photo);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        }
      } catch (_) {}
      return Image.asset(photo, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => _buildAvatarFallback());
    }
    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: const Color(0xFFEFF6FF),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0052FF),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uppercaseCompany = company.toUpperCase();
    final uppercaseStatus = status.toUpperCase();
    final gradientColors = _getGradientForTemplate(selectedTemplateIndex);
    final photo = bannerUrl ?? bannerAsset;
    final hasBannerImage = photo != null && photo.isNotEmpty;
    final isLightTemplate = selectedTemplateIndex == 4;

    return Column(
      children: [
        // Banner Header with Overlapping Avatar
        SizedBox(
          height: 215,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Full-width rounded Banner Cover Container
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A0052FF),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Full-width Banner Graphic Overlay
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _buildBannerImage(),
                      ),
                    ),

                    // Gradient Mask: Dark vignette if custom image present, subtle match if template
                    if (hasBannerImage)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.60),
                                  Colors.black.withValues(alpha: 0.20),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Left Abstract Wave Lines & Brand Text
                    Positioned(
                      top: 16,
                      left: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "People\nBuild\nBetter\nFutures",
                            style: TextStyle(
                              color: (!hasBannerImage && isLightTemplate) ? const Color(0xFF0F172A) : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 24,
                            height: 2,
                            color: (!hasBannerImage && isLightTemplate) ? const Color(0xFF0F172A) : Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "$uppercaseCompany\nPEOPLE  •  PLACES  •  POSSIBILITIES",
                            style: TextStyle(
                              color: (!hasBannerImage && isLightTemplate) ? const Color(0xFF475569) : Colors.white.withValues(alpha: 0.85),
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Floating Badge Top Right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              uppercaseStatus,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Color(0xFF0066FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center-bottom Overlapping Circular Profile Avatar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Name, Title, and Company Header
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          role,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0066FF),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          company,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
