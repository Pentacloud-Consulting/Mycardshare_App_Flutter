import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../profile/individual_profile_store.dart';
import '../social_redirect/social_redirect_service.dart';

/// Helper widget to reliably decode and render an image from:
/// 1. Base64 Data URI ("data:image/...")
/// 2. Remote Network URL ("http://", "https://")
/// 3. Flutter Asset ("assets/...")
/// 4. Raw Base64 string
/// 5. Local File Path ("file://", "/data/...", "C:\...")
Widget buildWalletImageWidget(
  String? imagePath, {
  required Widget fallback,
  BoxFit fit = BoxFit.cover,
}) {
  if (imagePath == null || imagePath.trim().isEmpty) return fallback;
  final p = imagePath.trim();

  // 1. Data URI (Base64) - e.g. "data:image/jpeg;base64,/9j/4AAQ..."
  if (p.startsWith('data:image')) {
    try {
      final commaIdx = p.indexOf(',');
      final base64Str = commaIdx != -1 ? p.substring(commaIdx + 1) : p;
      final bytes = base64Decode(base64Str.trim());
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, st) => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }

  // 2. Remote Network Image
  if (p.startsWith('http://') || p.startsWith('https://')) {
    return Image.network(
      p,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (ctx, err, st) => fallback,
    );
  }

  // 3. Asset Image
  if (p.startsWith('assets/') || p.startsWith('asset/')) {
    return Image.asset(
      p,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (ctx, err, st) => fallback,
    );
  }

  // 4. Raw Base64 string
  if (!p.contains('/') && !p.contains('\\') && p.length > 100) {
    try {
      final bytes = base64Decode(p.trim());
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, st) => fallback,
      );
    } catch (_) {}
  }

  // 5. Local File Path or File URI (file://)
  try {
    if (kIsWeb) {
      return Image.network(
        p,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, st) => fallback,
      );
    }
    String cleanPath = p;
    if (cleanPath.startsWith('file://')) {
      try {
        cleanPath = Uri.parse(cleanPath).toFilePath();
      } catch (_) {
        cleanPath = cleanPath.replaceFirst('file://', '');
      }
    }
    final file = File(cleanPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, st) => fallback,
      );
    }
  } catch (_) {}

  return fallback;
}

/// Helper to render an icon for a given social platform
Widget buildWalletSocialIcon(String platform) {
  final p = platform.toLowerCase().trim();
  if (p.contains('linkedin')) {
    return const FaIcon(FontAwesomeIcons.linkedinIn, color: Color(0xFF0A66C2), size: 14);
  } else if (p.contains('instagram')) {
    return const FaIcon(FontAwesomeIcons.instagram, color: Color(0xFFE1306C), size: 14);
  } else if (p.contains('whatsapp')) {
    return const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 15);
  } else if (p.contains('github')) {
    return const FaIcon(FontAwesomeIcons.github, color: Colors.white, size: 14);
  } else if (p.contains('twitter') || p.contains('x')) {
    return const FaIcon(FontAwesomeIcons.xTwitter, color: Colors.white, size: 14);
  } else if (p.contains('youtube')) {
    return const FaIcon(FontAwesomeIcons.youtube, color: Color(0xFFFF0000), size: 14);
  } else if (p.contains('pinterest')) {
    return const FaIcon(FontAwesomeIcons.pinterest, color: Color(0xFFBD081C), size: 14);
  } else if (p.contains('telegram')) {
    return const FaIcon(FontAwesomeIcons.telegram, color: Color(0xFF26A5E4), size: 14);
  } else if (p.contains('facebook')) {
    return const FaIcon(FontAwesomeIcons.facebookF, color: Color(0xFF1877F2), size: 14);
  } else {
    return const FaIcon(FontAwesomeIcons.globe, color: Color(0xFF38BDF8), size: 14);
  }
}

/// Interactive chip for social platform that redirects when tapped
Widget buildWalletSocialChip({
  required BuildContext context,
  required SocialLinkItem item,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        SocialRedirectService.launchSocialPlatform(
          platform: item.platform,
          rawInput: item.url,
          context: context,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildWalletSocialIcon(item.platform),
            const SizedBox(width: 5),
            Text(
              item.platform.isNotEmpty ? item.platform : 'Link',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
