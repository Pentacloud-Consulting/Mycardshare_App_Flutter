import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/font style/font_style.dart';

/// Provider that maintains real-time internet connectivity status.
/// Defaults to true so it doesn't flicker during immediate app startup.
final internetConnectionProvider =
    StateNotifierProvider<InternetConnectionNotifier, bool>((ref) {
  return InternetConnectionNotifier();
});

class InternetConnectionNotifier extends StateNotifier<bool> {
  Timer? _pollingTimer;
  bool _isChecking = false;

  InternetConnectionNotifier() : super(true) {
    _startMonitoring();
  }

  void _startMonitoring() {
    // Immediate initial check
    checkConnectivity();
    // Poll every 3 seconds to auto-detect connect / disconnect
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkConnectivity();
    });
  }

  /// Checks real internet connectivity using DNS lookups
  Future<bool> checkConnectivity() async {
    if (_isChecking) return state;
    _isChecking = true;

    bool isConnected = false;
    try {
      final res = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (res.isNotEmpty && res[0].rawAddress.isNotEmpty) {
        isConnected = true;
      }
    } catch (_) {
      try {
        final fallback = await InternetAddress.lookup('1.1.1.1')
            .timeout(const Duration(seconds: 3));
        if (fallback.isNotEmpty && fallback[0].rawAddress.isNotEmpty) {
          isConnected = true;
        }
      } catch (_) {
        isConnected = false;
      }
    }

    _isChecking = false;
    if (mounted && state != isConnected) {
      state = isConnected;
    }
    return isConnected;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

/// Premium No-Internet Screen
/// Appears when mobile data/Wi-Fi is disconnected, and automatically disappears
/// as soon as internet connection is restored.
class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({super.key});

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _manualRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    final isOnline = await ref
        .read(internetConnectionProvider.notifier)
        .checkConnectivity();

    if (mounted) {
      setState(() => _isRetrying = false);
      if (!isOnline) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Still offline! Please verify your Wi-Fi or mobile data.",
              style: AppFontStyle.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent going back while offline
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulsing animated icon container
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 140 * _pulseScale.value,
                            height: 140 * _pulseScale.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0052FF)
                                  .withValues(alpha: _pulseOpacity.value * 0.15),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0052FF), Color(0xFF38BDF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0052FF).withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Heading
                  Text(
                    "No Internet Connection",
                    textAlign: TextAlign.center,
                    style: AppFontStyle.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    "You're currently offline. Please check your Wi-Fi or mobile data connection to resume.",
                    textAlign: TextAlign.center,
                    style: AppFontStyle.bodyMedium.copyWith(
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Offline notice badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFBFDBFE),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            "This page will auto-close when reconnected",
                            style: AppFontStyle.caption.copyWith(
                              color: const Color(0xFF1E40AF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isRetrying ? null : _manualRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0052FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isRetrying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Try Again",
                                  style: AppFontStyle.buttonText.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
