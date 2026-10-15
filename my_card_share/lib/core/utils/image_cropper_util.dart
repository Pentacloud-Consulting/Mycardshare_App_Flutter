import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

enum AppCropType {
  avatar,
  banner,
  logo,
  custom,
}

class AppImageCropper {
  AppImageCropper._();

  /// Crops an image with flexible adjustments (users can crop however they want)
  /// Returns the path to the cropped file, or the original path if cancelled/failed.
  static Future<String?> cropImage({
    required BuildContext context,
    required String sourcePath,
    AppCropType cropType = AppCropType.custom,
    String? title,
  }) async {
    try {
      final isAvatar = cropType == AppCropType.avatar || cropType == AppCropType.logo;
      final isBanner = cropType == AppCropType.banner;

      final defaultTitle = isAvatar
          ? (cropType == AppCropType.logo ? 'Adjust Company Logo' : 'Adjust Profile Photo')
          : (isBanner ? 'Adjust Cover Banner' : 'Crop & Adjust Image');

      final List<PlatformUiSettings> uiSettings = [
        AndroidUiSettings(
          toolbarTitle: title ?? defaultTitle,
          toolbarColor: const Color(0xFF0052FF),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF0052FF),
          initAspectRatio: isAvatar
              ? CropAspectRatioPreset.square
              : (isBanner ? CropAspectRatioPreset.ratio16x9 : CropAspectRatioPreset.original),
          lockAspectRatio: false, // User can freely adjust to any size
          cropStyle: isAvatar ? CropStyle.circle : CropStyle.rectangle,
          hideBottomControls: false,
          showCropGrid: true,
          aspectRatioPresets: isBanner
              ? [
                  CropAspectRatioPreset.ratio16x9,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
        IOSUiSettings(
          title: title ?? defaultTitle,
          cropStyle: isAvatar ? CropStyle.circle : CropStyle.rectangle,
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPresets: isBanner
              ? [
                  CropAspectRatioPreset.ratio16x9,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                ]
              : [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio3x2,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
        ),
      ];

      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        uiSettings: uiSettings,
      );

      if (cropped != null) {
        return cropped.path;
      }
      return null;
    } catch (e) {
      debugPrint('[AppImageCropper] Cropping note/fallback: $e');
      // If cropper fails or is cancelled, return the original file as fallback
      return sourcePath;
    }
  }
}
