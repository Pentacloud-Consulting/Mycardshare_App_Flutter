import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraScanModal extends StatefulWidget {
  const CameraScanModal({super.key});

  @override
  State<CameraScanModal> createState() => _CameraScanModalState();
}

class _CameraScanModalState extends State<CameraScanModal> {
  bool _isScanning = false;
  bool _isSuccess = false;
  String _scanStatus = "Position business card within the frame";

  void _triggerScan() async {
    setState(() {
      _isScanning = true;
      _scanStatus = "Capturing high-res card image...";
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() {
      _scanStatus = "AI analyzing layout & extracting text...";
    });

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _isScanning = false;
      _isSuccess = true;
      _scanStatus = "Contact extracted: Alex Morgan (Tech Lead)";
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    context.go('/portal/vault');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✓ Alex Morgan added to Contact Vault via AI Scan!"),
        backgroundColor: Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Scan Business Card",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Viewfinder Container
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AspectRatio(
                    aspectRatio: 1.58, // Standard credit/business card ratio
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isSuccess
                              ? const Color(0xFF22C55E)
                              : _isScanning
                                  ? const Color(0xFF0066FF)
                                  : Colors.white.withAlpha(80),
                          width: 2.5,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Corner Guidelines
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Icon(Icons.crop_free_rounded, color: _isSuccess ? const Color(0xFF22C55E) : Colors.white70, size: 28),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Icon(Icons.crop_free_rounded, color: _isSuccess ? const Color(0xFF22C55E) : Colors.white70, size: 28),
                          ),

                          // Inner Content/Scanning Simulation
                          Center(
                            child: _isSuccess
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 48),
                                      SizedBox(height: 8),
                                      Text(
                                        "Alex Morgan",
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "Tech Lead • NextGen Labs",
                                        style: TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  )
                                : _isScanning
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: CircularProgressIndicator(color: Color(0xFF0066FF), strokeWidth: 3),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            "AI OCR Scanning...",
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.credit_card_rounded, color: Colors.white38, size: 48),
                                          SizedBox(height: 8),
                                          Text(
                                            "Align card within frame",
                                            style: TextStyle(color: Colors.white60, fontSize: 13),
                                          ),
                                        ],
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Status Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                _scanStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isSuccess ? const Color(0xFF4ADE80) : Colors.white70,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Shutter Button Row
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0, top: 12.0),
              child: GestureDetector(
                onTap: _isScanning ? null : _triggerScan,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: const Color(0xFF0066FF),
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
