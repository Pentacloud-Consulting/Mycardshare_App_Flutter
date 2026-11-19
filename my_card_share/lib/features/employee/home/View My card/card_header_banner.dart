import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/image_url_formatter.dart';
import '../../../../backend/employee_join/banner fetch/banner fetch.dart';

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
  final bool isPublished;

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
    this.isPublished = true,
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

  Widget _buildImageWidget(String? photo, {required Widget fallback}) {
    final formatted = ImageUrlFormatter.format(photo);
    if (formatted == null || formatted.trim().isEmpty) return fallback;
    final p = formatted.trim();

    if (p.startsWith('data:image')) {
      try {
        final commaIdx = p.indexOf(',');
        final base64Str = commaIdx != -1 ? p.substring(commaIdx + 1) : p;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (ctx, err, st) => fallback,
        );
      } catch (_) {
        return fallback;
      }
    }

    if (p.startsWith('http://') || p.startsWith('https://')) {
      return Image.network(
        p,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: 600,
        errorBuilder: (ctx, err, st) => fallback,
      );
    }

    if (p.startsWith('assets/') || p.startsWith('asset/')) {
      return Image.asset(p, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => fallback);
    }

    try {
      if (kIsWeb) {
        return Image.network(p, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => fallback);
      }
      final file = File(p);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, errorBuilder: (ctx, err, st) => fallback);
      }
    } catch (_) {}

    return fallback;
  }

  Widget _buildBannerImage(String? effectiveBanner) {
    return _buildImageWidget(effectiveBanner, fallback: const SizedBox.shrink());
  }

  Widget _buildAvatarImage() {
    final authUser = FirebaseAuth.instance.currentUser;
    final googlePhoto = (authUser?.photoURL != null && authUser!.photoURL!.trim().isNotEmpty)
        ? authUser.photoURL!.trim()
        : null;
    final photo = (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
        ? avatarUrl!.trim()
        : ((avatarAsset != null && avatarAsset!.trim().isNotEmpty)
            ? avatarAsset!.trim()
            : googlePhoto);
    return _buildImageWidget(photo, fallback: _buildAvatarFallback());
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
    final uppercaseStatus = status.toUpperCase();
    final gradientColors = _getGradientForTemplate(selectedTemplateIndex);
    
    // Resolve effective banner URL: direct banner -> banner asset -> enterprise brand banner / logo
    final effectiveBanner = (bannerUrl != null && bannerUrl!.trim().isNotEmpty)
        ? bannerUrl!.trim()
        : ((bannerAsset != null && bannerAsset!.trim().isNotEmpty)
            ? bannerAsset!.trim()
            : EmployeeBannerFetchService.instance.getEffectiveBanner(null));
    final hasBannerImage = effectiveBanner != null && effectiveBanner.isNotEmpty;

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
                  borderRadius: BorderRadius.circular(24),
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
                    if (hasBannerImage)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: _buildBannerImage(effectiveBanner),
                        ),
                      ),

                    // Clean white bottom fade overlay matching Web
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: hasBannerImage ? 0.35 : 0.0),
                                Colors.white.withValues(alpha: hasBannerImage ? 0.85 : 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Floating Badge Top Right (ACTIVELY NETWORKING)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
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
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x6610B981),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isPublished ? uppercaseStatus : "INACTIVE",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Color(0xFF10B981),
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
                          color: Color(0x22000000),
                          blurRadius: 16,
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
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          role,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        if (company.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
              Flexible(
                child: Text(
                  company.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
