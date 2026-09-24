import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../profile/individual_profile_store.dart';
import 'individual_qr_service.dart';

/// Flutter component for rendering dynamic QR codes and displaying the Scan QR modal
class IndividualGenerateQR extends StatelessWidget {
  final String? cardSlug;
  final double size;

  const IndividualGenerateQR({
    super.key,
    this.cardSlug,
    this.size = 200.0,
  });

  /// Helper static method to open the QR modal popup anywhere (Matching Image 3)
  static void showModal(BuildContext context, {String? cardSlug, String? name}) {
    final active = IndividualProfileStore.instance.activeProfile;
    final slug = cardSlug ?? active?.cardSlug ?? IndividualProfileStore.generateCardSlug('user');
    final displayName = name ?? active?.fullName ?? 'User';
    final shareUrl = IndividualQRService.generateShareUrl(slug);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: const Color(0xFFF8FAFC),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Title & Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic QR Code Rendering Box (Image 3 exact styling)
              Container(
                width: 210,
                height: 210,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: QrImageView(
                    data: shareUrl,
                    version: QrVersions.auto,
                    size: 180.0,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF0052FF),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF0052FF),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Subtitle Text
              Text(
                "Scan to save $displayName's contact card instantly",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 20),

              // Done Primary Blue Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0052FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = IndividualProfileStore.instance.activeProfile;
    final slug = cardSlug ?? active?.cardSlug ?? IndividualProfileStore.generateCardSlug('user');
    final shareUrl = IndividualQRService.generateShareUrl(slug);

    return QrImageView(
      data: shareUrl,
      version: QrVersions.auto,
      size: size,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF0052FF),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF0052FF),
      ),
    );
  }
}
