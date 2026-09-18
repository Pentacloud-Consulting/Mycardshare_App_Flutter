import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_style_widgets.dart';
import '../../../../services/Individual/scanner/individual.dart';

class CameraScanModal extends StatefulWidget {
  const CameraScanModal({super.key});

  @override
  State<CameraScanModal> createState() => _CameraScanModalState();
}

class _CameraScanModalState extends State<CameraScanModal> with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  String _scanStatus = "Initializing camera...";
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  CameraController? _cameraController;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _scanStatus = "No cameras found");
        return;
      }
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _scanStatus = "Position business card within the frame";
        });
      }
    } catch (e) {
      setState(() => _scanStatus = "Camera error: $e");
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _triggerScan([String? customName]) async {
    if (_isScanning) return;
    
    // Take picture if using camera
    if (customName == null && _cameraController != null && _cameraController!.value.isInitialized) {
      try {
        _capturedImage = await _cameraController!.takePicture();
      } catch (e) {
        debugPrint("Error capturing image: $e");
      }
    }

    setState(() {
      _isScanning = true;
      _scanStatus = "AI analyzing layout & extracting text...";
    });
    
    _animController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    _animController.stop();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        SmoothPageRoute(
          page: ReviewDetailsScreen(
            tag: 'OCR',
            initialName: customName ?? "Robert Chen",
            initialRole: "Managing Director",
            initialCompany: "Apex Global Ventures",
            initialPhone: "+1 415 555 9876",
            initialEmail: "robert.chen@apexglobal.com",
            initialWebsite: "www.apexglobal.com",
            initialAddress: "500 California St, San Francisco, CA",
          ),
        ),
      );
    }
  }

  void _pickFromGallery() {
    _triggerScan("Gallery Contact");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Scan Business Card",
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Viewfinder Container (Image 2 style frame)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AspectRatio(
                    aspectRatio: 1.58, // Standard card ratio
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isScanning ? AppColors.primary : const Color(0xFF475569),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Camera feed or captured image
                          Positioned.fill(
                            child: _capturedImage != null
                                ? Image.file(
                                    File(_capturedImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                : (_cameraController != null && _cameraController!.value.isInitialized)
                                    ? CameraPreview(_cameraController!)
                                    : const SizedBox(),
                          ),
                          
                          // Dark overlay to make scanning frame visible over camera feed
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                          ),
                          // Top-left Corner Bracket
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Icon(Icons.crop_free_rounded, color: Colors.white.withValues(alpha: 0.8), size: 32),
                          ),
                          // Bottom-right Corner Bracket
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Icon(Icons.crop_free_rounded, color: Colors.white.withValues(alpha: 0.8), size: 32),
                          ),

                          // Center Card Icon & Text
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.credit_card_rounded,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Align card within frame",
                                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Animated Scan Line when capturing
                          if (_isScanning)
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: _scanAnimation.value * 180,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withValues(alpha: 0.0),
                                          AppColors.primary,
                                          AppColors.primary.withValues(alpha: 0.0),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary,
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Button below Image 2: "Upload from Gallery"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: ClayButton(
                label: "Upload from Gallery",
                icon: Icons.photo_library_rounded,
                onTap: _pickFromGallery,
              ),
            ),

            // Status Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Text(
                _scanStatus,
                textAlign: TextAlign.center,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Camera Capture Button (Image 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0, top: 8.0),
              child: GestureDetector(
                onTap: () => _triggerScan(),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 32),
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

