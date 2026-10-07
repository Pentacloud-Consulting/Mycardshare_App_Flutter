import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../backend/app view/app_view_auth_gate.dart';

/// Beautiful Splash Animation Screen for My Card Share
class SplashAnimationScreen extends ConsumerStatefulWidget {
  const SplashAnimationScreen({super.key});

  @override
  ConsumerState<SplashAnimationScreen> createState() =>
      _SplashAnimationScreenState();
}

class _SplashAnimationScreenState extends ConsumerState<SplashAnimationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _textController;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  late final AnimationController _exitController;
  late final Animation<double> _exitFadeAnimation;
  late final Animation<double> _exitScaleAnimation;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // 1. Logo Entrance Animation (0 to 1.2s)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // 2. Continuous Pulse Glowing Ring (Breathing effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // 3. Text Slide & Fade Animation (Delayed start: 500ms -> 1300ms)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 4. Exit Animation (for smooth transition)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeOut,
      ),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeOut,
      ),
    );

    // Kick off animation sequence
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });

    // Start navigation timer after splash duration
    _initiateNavigationTimer();
  }

  Future<void> _initiateNavigationTimer() async {
    // Keep splash on screen for a minimum of 2.6 seconds to showcase the animation
    await Future.delayed(const Duration(milliseconds: 2600));

    if (!mounted || _isNavigating) return;

    // Double check auth session restoration if needed
    AuthState authState = ref.read(authProvider);

    // If auth state is still loading default, check AppViewAuthGate directly
    if (!authState.isLoggedIn && AppViewAuthGate.instance.hasActiveSession) {
      final userModel = await AppViewAuthGate.instance.restoreSessionOnAppLaunch();
      if (userModel != null) {
        authState = AuthState(
          isLoggedIn: true,
          role: userModel.role,
          user: userModel,
        );
      }
    }

    _isNavigating = true;

    // Run exit fade animation before routing
    await _exitController.forward();

    if (!mounted) return;

    // Mark splash as completed so router allows navigation to main screens
    ref.read(splashCompletedProvider.notifier).state = true;

    if (authState.isLoggedIn) {
      final role = authState.role.toLowerCase();
      debugPrint('[SplashAnimation] User is logged in as role: $role. Directing to home screen.');
      if (role == 'master-admin' || role == 'master_admin') {
        context.go('/master-admin/dashboard');
      } else if (role == 'enterprise' || role == 'employee') {
        context.go('/enterprise/dashboard');
      } else {
        // Individual Portal Home Page (Image 2)
        context.go('/portal');
      }
    } else {
      debugPrint('[SplashAnimation] User is not logged in. Directing to Onboarding (Image 1).');
      // Onboarding Screen (Image 1)
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Premium Dark Navy
      body: AnimatedBuilder(
        animation: _exitController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitFadeAnimation,
            child: ScaleTransition(
              scale: _exitScaleAnimation,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Ambient Glowing Background Gradients
            Positioned(
              top: -120,
              left: -100,
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.35),
                      const Color(0xFF0052FF).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -80,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.25),
                      const Color(0xFF0066FF).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Center Splash Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Logo Container with Pulsing Halo Glow
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoController, _pulseController]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Pulsing Glow Ring
                                Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF0066FF).withValues(alpha: 0.40),
                                          const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Glassmorphic Card Backing for Logo
                                Container(
                                  width: 136,
                                  height: 136,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                                        blurRadius: 32,
                                        spreadRadius: 4,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(68),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Image.asset(
                                        'assets/images/logo/MYSHAREFAVO.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.style_rounded,
                                            size: 64,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // App Title & Tagline with Slide & Fade
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _textSlideAnimation,
                          child: Opacity(
                            opacity: _textFadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // App Title with Gradient Text
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFE2E8F0),
                                Color(0xFF38BDF8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              "MY CARD SHARE",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Subtitle Badge / Tagline
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              "Every Connection Starts a New Opportunity",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Subtle Bottom Loading Shimmer Dots
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return _SplashLoadingDot(index: index);
                            }),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),
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

/// Helper Widget for smooth animated pulsing loading dots at bottom
class _SplashLoadingDot extends StatefulWidget {
  final int index;
  const _SplashLoadingDot({required this.index});

  @override
  State<_SplashLoadingDot> createState() => _SplashLoadingDotState();
}

class _SplashLoadingDotState extends State<_SplashLoadingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 220), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF38BDF8)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0066FF).withValues(alpha: 0.6),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Typedef alias for backwards compatibility
typedef SplashAnimation = SplashAnimationScreen;


