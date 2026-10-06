import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsUserProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  const SettingsUserProfileCard({
    super.key,
    this.name = "User",
    this.email = "",
    this.avatarUrl,
  });

  Widget _buildAvatarWidget(String? photo, String userName) {
    if (photo != null && photo.trim().isNotEmpty) {
      final p = photo.trim();
      if (p.startsWith('http://') || p.startsWith('https://')) {
        return Image.network(
          p,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => _buildAvatarFallback(userName),
        );
      } else {
        try {
          if (kIsWeb) {
            return Image.network(
              p,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, st) => _buildAvatarFallback(userName),
            );
          } else {
            final file = File(p);
            if (file.existsSync()) {
              return Image.file(file, fit: BoxFit.cover);
            }
          }
        } catch (_) {}
      }
    }
    return _buildAvatarFallback(userName);
  }

  Widget _buildAvatarFallback(String userName) {
    final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'U';
    return Container(
      color: const Color(0xFF0052FF),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Avatar with light gradient ring
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
              ),
            ),
            child: SizedBox(
              width: 56,
              height: 56,
              child: ClipOval(
                child: _buildAvatarWidget(avatarUrl, name),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "User",
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Edit Button
          TextButton(
            onPressed: () => context.push('/portal/profile'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              "Edit",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
