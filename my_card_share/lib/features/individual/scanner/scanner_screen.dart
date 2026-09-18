import 'package:flutter/material.dart';
import 'widgets/camera_scan_modal.dart';
import 'widgets/manual_add_contact_dialog.dart';
import 'widgets/manual_entry_button.dart';
import 'widgets/scan_option_card.dart';
import 'widgets/voice_scan_modal.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  void _openCameraScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScanModal()),
    );
  }

  void _openVoiceScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VoiceScanModal()),
    );
  }

  void _openManualAdd(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ManualAddContactDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Options Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Option 1: Scan a Card
                    ScanOptionCard(
                      title: "Scan a Card",
                      subtitle: "Snap a photo of a business card — AI extracts the details instantly",
                      icon: Icons.camera_alt_rounded,
                      gradientColors: const [
                        Color(0xFF00C6FF),
                        Color(0xFF0072FF),
                      ],
                      onTap: () => _openCameraScan(context),
                    ),

                    const SizedBox(height: 16),

                    // Option 2: Voice Add
                    ScanOptionCard(
                      title: "Voice Add",
                      subtitle: "Just say the details out loud — AI turns it into a contact",
                      icon: Icons.mic_rounded,
                      gradientColors: const [
                        Color(0xFFA855F7),
                        Color(0xFFEC4899),
                      ],
                      onTap: () => _openVoiceScan(context),
                    ),

                    const SizedBox(height: 28),

                    // Divider & Enter Manually Button
                    ManualEntryButton(
                      onTap: () => _openManualAdd(context),
                    ),

                    const SizedBox(height: 36),

                    // Footer Note
                    const Center(
                      child: Text(
                        "Your scans are saved to your Contact Vault automatically",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
