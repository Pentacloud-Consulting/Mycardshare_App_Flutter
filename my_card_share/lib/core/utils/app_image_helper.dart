import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class AppImageHelper {
  AppImageHelper._();

  /// Builds an Image widget from any format:
  /// - Base64 Data URI ('data:image/...;base64,...')
  /// - Plain base64 string
  /// - Remote URL ('http://...', 'https://...')
  /// - Local File path ('/data/...', 'C:\...')
  /// - Asset path ('assets/...')
  static Widget buildImage(
    String? pathOrUrl, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? fallback,
    BorderRadius? borderRadius,
  }) {
    final Widget placeholder = fallback ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFEFF6FF),
          child: const Icon(Icons.image_outlined, color: Color(0xFF64748B), size: 28),
        );

    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) {
      return placeholder;
    }

    final p = pathOrUrl.trim();
    Widget imgWidget;

    // 1. Data URI / Base64
    if (p.startsWith('data:image')) {
      try {
        final commaIdx = p.indexOf(',');
        final base64Str = commaIdx != -1 ? p.substring(commaIdx + 1) : p;
        final bytes = base64Decode(base64Str.trim());
        imgWidget = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, error, stackTrace) => placeholder,
        );
      } catch (_) {
        imgWidget = placeholder;
      }
    }
    // 2. Remote Network URL
    else if (p.startsWith('http://') || p.startsWith('https://')) {
      imgWidget = Image.network(
        p,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, error, stackTrace) => placeholder,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0052FF)),
              ),
            ),
          );
        },
      );
    }
    // 3. Asset Image
    else if (p.startsWith('assets/') || p.startsWith('asset/')) {
      imgWidget = Image.asset(
        p,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, error, stackTrace) => placeholder,
      );
    }
    // 4. Local File path
    else {
      try {
        final file = File(p);
        if (file.existsSync()) {
          imgWidget = Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, error, stackTrace) => placeholder,
          );
        } else {
          // Attempt raw base64 decode if string length is large
          if (p.length > 100 && !p.contains(Platform.pathSeparator)) {
            final bytes = base64Decode(p);
            imgWidget = Image.memory(
              bytes,
              fit: fit,
              width: width,
              height: height,
              errorBuilder: (_, error, stackTrace) => placeholder,
            );
          } else {
            imgWidget = placeholder;
          }
        }
      } catch (_) {
        imgWidget = placeholder;
      }
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: imgWidget);
    }
    return imgWidget;
  }

  /// Returns an ImageProvider supporting both remote URLs, base64 data URIs, and local files.
  static ImageProvider? getImageProvider(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.trim().isEmpty) return null;
    final p = pathOrUrl.trim();

    if (p.startsWith('data:image')) {
      try {
        final commaIdx = p.indexOf(',');
        final base64Str = commaIdx != -1 ? p.substring(commaIdx + 1) : p;
        return MemoryImage(base64Decode(base64Str.trim()));
      } catch (_) {
        return null;
      }
    } else if (p.startsWith('http://') || p.startsWith('https://')) {
      return NetworkImage(p);
    } else if (p.startsWith('assets/') || p.startsWith('asset/')) {
      return AssetImage(p);
    } else {
      try {
        final file = File(p);
        if (file.existsSync()) {
          return FileImage(file);
        }
        if (p.length > 100) {
          return MemoryImage(base64Decode(p));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
