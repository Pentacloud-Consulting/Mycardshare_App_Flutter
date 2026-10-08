import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/back/smart_back_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_style_widgets.dart';
import '../../../../services/Individual/scanner/individual.dart';
import '../../dynamic_view/qr_redirect_handler.dart';
import '../../../../backend/individual/scan/card_scan_service.dart';

class CameraScanModal extends StatefulWidget {
  const CameraScanModal({super.key});

  @override
  State<CameraScanModal> createState() => _CameraScanModalState();
}

class _CameraScanModalState extends State<CameraScanModal>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _isPickingFromGallery = false;
  String _scanStatus = 'Initializing camera...';
  late AnimationController _animController;
  late Animation<double> _scanAnimation;

  CameraController? _cameraController;
  File? _previewFile; // shown in viewfinder after capture / gallery pick

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
        if (mounted) setState(() => _scanStatus = 'No cameras found on device');
        return;
      }
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _scanStatus = 'Position business card within the frame');
      }
    } catch (e) {
      if (mounted) setState(() => _scanStatus = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // ── OCR processing ─────────────────────────────────────────────────────────

  Future<void> _runOcrAndNavigate(String imagePath) async {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _scanStatus = 'AI analyzing layout & extracting text...';
    });
    _animController.repeat(reverse: true);

    try {
      final ScannedContactData contact =
          await CardScanService.instance.processCardScan(imagePath: imagePath);

      _animController.stop();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        SmoothPageRoute(
          page: ReviewDetailsScreen(
            tag: 'OCR',
            initialName: contact.name,
            initialRole: contact.role,
            initialCompany: contact.company,
            initialPhone: contact.phone,
            initialEmail: contact.email,
            initialWebsite: contact.website,
            initialAddress: contact.address,
            initialImagePath: contact.imagePath ?? imagePath,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[CameraScanModal] OCR error: $e');
      _animController.stop();
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanStatus = 'Could not read card — try again or upload from gallery';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OCR failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── Camera capture ─────────────────────────────────────────────────────────

  Future<void> _captureAndScan() async {
    if (_isScanning) return;
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() => _scanStatus = 'Camera not ready — use Upload from Gallery');
      return;
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      setState(() {
        _previewFile = File(file.path);
        _scanStatus = 'Card captured — running AI OCR...';
      });
      await _runOcrAndNavigate(file.path);
    } catch (e) {
      if (mounted) {
        setState(() => _scanStatus = 'Capture error: $e');
      }
    }
  }

  // ── Gallery pick ───────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    if (_isScanning || _isPickingFromGallery) return;
    setState(() => _isPickingFromGallery = true);

    try {
      final picker = ImagePicker();
      final XFile? picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 95);

      if (picked == null) {
        if (mounted) setState(() => _isPickingFromGallery = false);
        return;
      }

      if (mounted) {
        setState(() {
          _previewFile = File(picked.path);
          _isPickingFromGallery = false;
          _scanStatus = 'Image selected — running AI OCR...';
        });
      }

      await _runOcrAndNavigate(picked.path);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPickingFromGallery = false;
          _scanStatus = 'Gallery error: $e';
        });
      }
    }
  }

  // ── QR code handler ────────────────────────────────────────────────────────

  Future<void> handleScannedQrCode(String scannedValue) async {
    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _scanStatus = 'Reading card…';
    });
    _animController.forward();
    await QrRedirectHandler.handle(context, scannedValue);
    if (mounted) {
      setState(() {
        _isScanning = false;
        _scanStatus = 'Position business card within the frame';
      });
      _animController.reset();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded,
              color: AppColors.textPrimary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Business Card',
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

            // ── Viewfinder ──────────────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: AspectRatio(
                    aspectRatio: 1.58,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isScanning
                              ? AppColors.primary
                              : const Color(0xFF475569),
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
                          // Live camera feed OR captured image preview
                          Positioned.fill(
                            child: _previewFile != null
                                ? (kIsWeb
                                    ? Image.network(
                                        _previewFile!.path,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const _NoCameraPlaceholder(),
                                      )
                                    : Image.file(
                                        _previewFile!,
                                        fit: BoxFit.cover,
                                      ))
                                : (_cameraController != null &&
                                        _cameraController!.value.isInitialized)
                                    ? CameraPreview(_cameraController!)
                                    : const _NoCameraPlaceholder(),
                          ),

                          // Dim overlay
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.15),
                            ),
                          ),

                          // Corner brackets
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Icon(Icons.crop_free_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 32),
                          ),
                          Positioned(
                            bottom: 14,
                            right: 14,
                            child: Icon(Icons.crop_free_rounded,
                                color: Colors.white.withValues(alpha: 0.85),
                                size: 32),
                          ),

                          // Center hint (only when no image captured yet)
                          if (_previewFile == null && !_isScanning)
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
                                    'Align card within frame',
                                    style: AppTextStyles.textTheme.bodyMedium
                                        ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Scanning animation overlay
                          if (_isScanning) ...[
                            Positioned.fill(
                              child: Container(
                                color: AppColors.primary.withValues(alpha: 0.08),
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (ctx, _) => Positioned(
                                top: _scanAnimation.value * 170,
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
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Upload from Gallery button ───────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: _isPickingFromGallery
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  : ClayButton(
                      label: 'Upload from Gallery',
                      icon: Icons.photo_library_rounded,
                      onTap: _pickFromGallery,
                    ),
            ),

            // ── Status text ──────────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Text(
                _scanStatus,
                textAlign: TextAlign.center,
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ── Camera capture button ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0, top: 4.0),
              child: GestureDetector(
                onTap: _isScanning ? null : _captureAndScan,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color:
                        _isScanning ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isScanning
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 32),
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

/// Shown inside viewfinder when camera is unavailable (permission denied, no camera).
class _NoCameraPlaceholder extends StatelessWidget {
  const _NoCameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E293B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_photography_rounded,
              color: Colors.white.withValues(alpha: 0.4), size: 48),
          const SizedBox(height: 12),
          Text(
            'Camera unavailable\nUse "Upload from Gallery" instead',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


