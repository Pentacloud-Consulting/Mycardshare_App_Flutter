import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../Nav/portal_bottom_nav.dart';
import '../../Nav/portal_top_nav.dart';
import '../../individual/home/View My card/home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _animController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  final List<Map<String, dynamic>> _slides = [
    {
      "title_line1": "Every Connection",
      "title_line2": "Starts a New",
      "title_highlight": "Opportunity",
      "subtitle": "Share your professional identity, instantly.",
      "button_text": "Get Started",
    },
    {
      "title_line1": "Share Anywhere —",
      "title_line2": "",
      "title_highlight": "QR, Link, or Tap",
      "subtitle": "No app needed for the person you're sharing with.",
      "button_text": "Continue",
    },
    {
      "title_line1": "Track Every",
      "title_line2": "",
      "title_highlight": "View, Scan & Lead",
      "subtitle": "Real intelligence — know who's engaging and how.",
      "button_text": "Get Started",
    },
  ];

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: Stack(
        children: [
          // Background ambient gradient glows
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0066FF).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF38B6FF).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header: Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text("Skip"),
                    ),
                  ),
                ),

                // Main Slide Text Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 28,
                            height: 1.18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                          children: [
                            if (slide["title_line1"].toString().isNotEmpty)
                              TextSpan(text: "${slide["title_line1"]}\n"),
                            if (slide["title_line2"].toString().isNotEmpty)
                              TextSpan(text: "${slide["title_line2"]}\n"),
                            TextSpan(
                              text: slide["title_highlight"],
                              style: const TextStyle(
                                color: Color(0xFF0066FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        slide["subtitle"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // PageView Graphics Area
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentPage = idx;
                      });
                    },
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      if (index == 0) return _buildSlide1Graphic();
                      if (index == 1) return _buildSlide2Graphic();
                      return _buildSlide3Graphic();
                    },
                  ),
                ),

                // Bottom Controls Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (idx) {
                          final isSelected = _currentPage == idx;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 7,
                            width: 7,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0066FF)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Primary Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0052FF), Color(0xFF00A2FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0066FF).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slide["button_text"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SLIDE 1 GRAPHIC: 3D Phone + Floating Cards
  // --------------------------------------------------------------------------
  Widget _buildSlide1Graphic() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {
            return Center(
              child: Transform.translate(
                offset: Offset(0, _floatAnimation.value * 0.5),
                child: Container(
                  width: constraints.maxWidth * 0.58,
                  height: constraints.maxHeight * 0.82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            child: const SizedBox(
                              width: 390,
                              height: 844,
                              child: IgnorePointer(
                                child: _MockIndividualCardScreen(showBottomNav: false),
                              ),
                            ),
                          ),
                        ),
                        // iPhone Notch at top center
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 68,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }



  // --------------------------------------------------------------------------
  // SLIDE 2 GRAPHIC: Share Anywhere (Node Diagram & QR Card)
  // --------------------------------------------------------------------------
  Widget _buildSlide2Graphic() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.translate(
              offset: const Offset(0, -20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Dashed Circle Canvas connecting the 3 node orbs
                  SizedBox(
                    width: constraints.maxWidth * 0.62,
                    height: constraints.maxWidth * 0.62,
                    child: CustomPaint(
                      painter: DashedNodeCirclePainter(),
                    ),
                  ),

                  // Center Phone Graphic with NFC Wave
                  Transform.translate(
                    offset: Offset(0, _floatAnimation.value * 0.8),
                    child: Container(
                      width: 92,
                      height: 156,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0F172A), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Container(
                            width: 26,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0F2FE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.wifi_tethering,
                                  color: Color(0xFF0066FF),
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top Node Orb: QR Code
                  Positioned(
                    top: constraints.maxHeight * 0.12,
                    child: Transform.translate(
                      offset: Offset(0, -_floatAnimation.value * 0.7),
                      child: _buildNodeOrb(
                        icon: Icons.qr_code_2,
                        label: "QR Code",
                      ),
                    ),
                  ),

                  // Bottom-Left Node Orb: Share Link
                  Positioned(
                    bottom: constraints.maxHeight * 0.35,
                    left: constraints.maxWidth * 0.11,
                    child: Transform.translate(
                      offset: Offset(0, _floatAnimation.value * 0.6),
                      child: _buildNodeOrb(
                        icon: Icons.link,
                        label: "Share Link",
                      ),
                    ),
                  ),

                  // Bottom-Right Node Orb: NFC Tap
                  Positioned(
                    bottom: constraints.maxHeight * 0.35,
                    right: constraints.maxWidth * 0.11,
                    child: Transform.translate(
                      offset: Offset(0, _floatAnimation.value * 0.6),
                      child: _buildNodeOrb(
                        icon: Icons.sensors,
                        label: "NFC Tap",
                      ),
                    ),
                  ),

                  // Bottom Center Floating Card: High-Res QR Code Card
                  Positioned(
                    bottom: constraints.maxHeight * 0.08,
                    child: Transform.translate(
                      offset: Offset(0, -_floatAnimation.value * 0.5),
                      child: Container(
                        width: 136,
                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0066FF).withValues(alpha: 0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code_2,
                                  size: 70,
                                  color: Color(0xFF0F172A),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0066FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.style, color: Colors.white, size: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              "Scan to view card",
                              style: TextStyle(
                                fontSize: 8.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for Node Orbs in Slide 2
  Widget _buildNodeOrb({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF0066FF), size: 22),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // SLIDE 3 GRAPHIC: Growth Dashboard & Real Analytics
  // --------------------------------------------------------------------------
  Widget _buildSlide3Graphic() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Floating 3D Dashboard Card
            Container(
              width: constraints.maxWidth * 0.68,
              height: constraints.maxHeight * 0.80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "MyCardShare",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                "Your Growth Dashboard",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Text("Last 7 Days", style: TextStyle(fontSize: 8, color: Color(0xFF64748B))),
                            Icon(Icons.arrow_drop_down, size: 12, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 4 Metric Cards Row
                  Row(
                    children: [
                      Expanded(child: _buildMetricMiniCard(Icons.visibility_outlined, "Views", "12,847", "↑ 28%")),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMetricMiniCard(Icons.qr_code_2, "QR Scans", "3,214", "↑ 42%")),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMetricMiniCard(Icons.people_outline, "Leads", "641", "↑ 36%")),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMetricMiniCard(Icons.bar_chart, "Conv. Rate", "4.99%", "↑ 18%")),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Daily Bar Chart Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Views & Leads — Daily",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.circle, size: 6, color: Color(0xFF0066FF)),
                          SizedBox(width: 3),
                          Text("Views", style: TextStyle(fontSize: 7, color: Color(0xFF64748B))),
                          SizedBox(width: 8),
                          Icon(Icons.circle, size: 6, color: Color(0xFF78C7FF)),
                          SizedBox(width: 3),
                          Text("Leads", style: TextStyle(fontSize: 7, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Y-Axis Labels Column
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text("2K", style: TextStyle(fontSize: 6.5, color: Color(0xFF94A3B8))),
                              Text("1.5K", style: TextStyle(fontSize: 6.5, color: Color(0xFF94A3B8))),
                              Text("1K", style: TextStyle(fontSize: 6.5, color: Color(0xFF94A3B8))),
                              Text("500", style: TextStyle(fontSize: 6.5, color: Color(0xFF94A3B8))),
                              Text("0", style: TextStyle(fontSize: 6.5, color: Color(0xFF94A3B8))),
                              SizedBox(height: 10), // spacing for bottom day labels
                            ],
                          ),
                          const SizedBox(width: 8),

                          // Chart Bars Area with Horizontal Grid Lines
                          Expanded(
                            child: Stack(
                              children: [
                                // Horizontal Grid Lines
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    5,
                                    (index) => Container(
                                      height: 1,
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                  ),
                                ),

                                // Bar Groups
                                Positioned.fill(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildBarGroup("Mon", 0.55, 0.28),
                                      _buildBarGroup("Tue", 0.52, 0.26),
                                      _buildBarGroup("Wed", 0.64, 0.30),
                                      _buildBarGroup("Thu", 0.54, 0.27),
                                      _buildBarGroup("Fri", 0.78, 0.42),
                                      _buildBarGroup("Sat", 0.90, 0.48),
                                      _buildBarGroup("Sun", 0.98, 0.52),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Traffic Sources Section
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Traffic Sources",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            _buildTrafficProgress("QR Code", 0.45, "45%"),
                            _buildTrafficProgress("Direct Link", 0.28, "28%"),
                            _buildTrafficProgress("NFC Tap", 0.18, "18%"),
                            _buildTrafficProgress("Social Media", 0.09, "9%"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.trending_up, color: Color(0xFF0066FF), size: 18),
                              SizedBox(height: 4),
                              Text(
                                "More\nConnections\nBrighter\nOpportunities",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0066FF),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Mini Metric Card for Slide 3
  Widget _buildMetricMiniCard(IconData icon, String title, String value, String percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF0066FF)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 7, color: Color(0xFF64748B))),
          const SizedBox(height: 1),
          Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 1),
          Text(percent, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
        ],
      ),
    );
  }

  // Bar Group for Slide 3 Chart
  Widget _buildBarGroup(String day, double heightFactor1, double heightFactor2) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 9,
              height: 145 * heightFactor1,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0052FF), Color(0xFF0077FF)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 9,
              height: 145 * heightFactor2,
              decoration: BoxDecoration(
                color: const Color(0xFF78C7FF),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(day, style: const TextStyle(fontSize: 7.5, color: Color(0xFF94A3B8))),
      ],
    );
  }

  // Traffic Source Progress Bar for Slide 3
  Widget _buildTrafficProgress(String label, double factor, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(fontSize: 7, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: factor,
                minHeight: 5,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            percentage,
            style: const TextStyle(fontSize: 7, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for dashed node circle in Slide 2
class DashedNodeCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0066FF).withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    double dashWidth = 5;
    double dashSpace = 4;
    double circumference = 2 * 3.141592653589793 * radius;
    int count = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < count; i++) {
      double startAngle = (i * (dashWidth + dashSpace) / radius);
      double sweepAngle = (dashWidth / radius);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Real Miniaturized Mock of IndividualCardScreen for Slide 1
// -----------------------------------------------------------------------------
class _MockIndividualCardScreen extends StatelessWidget {
  final bool showBottomNav;

  const _MockIndividualCardScreen({
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final name = "Alex Stanton";
    final role = "Director of Partnerships";
    final company = "My Card Share";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: showBottomNav ? PortalTopNav(userName: name.split(' ').first) : null,
      bottomNavigationBar: showBottomNav ? const PortalBottomNav() : null,
      body: Stack(
        children: [
          // Soft baby-blue gradient ambient glow top right
          Positioned(
            top: -50,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.7,
                    colors: [
                      const Color(0xFF38BDF8).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // Image 1: Header Banner with Overlapping Avatar & Info
                  CardHeaderBanner(
                    name: name,
                    role: role,
                    company: company,
                  ),

                  const SizedBox(height: 18),

                  // Image 2: Quick Action Pill Buttons (Email & Call)
                  const CardQuickActions(),

                  const SizedBox(height: 14),

                  // Image 3: Quote Bio Card
                  const CardBioQuoteCard(),

                  const SizedBox(height: 18),

                  // Image 4: Social Icon Row
                  const CardSocialRow(),

                  const SizedBox(height: 20),

                  // Image 5: Save Contact, Secondary Buttons & Center QR Button
                  CardFooterActions(name: name, showBranding: false),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
