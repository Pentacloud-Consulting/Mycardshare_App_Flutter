import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title_black": "Your Professional\nIdentity, ",
      "title_blue": "Serialized.",
      "align": TextAlign.start,
    },
    {
      "title_black": "Your Business Card\n",
      "title_blue": "Reinvented",
      "align": TextAlign.center,
    },
    {
      "title_black": "Share Instantly\n",
      "title_blue": "Anywhere, Anytime",
      "align": TextAlign.center,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE8F4FF),
              Color(0xFF3A98EC),
            ],
            stops: [0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: const [
                        Icon(Icons.credit_card, color: Color(0xFF003F9A), size: 36),
                        Positioned(
                          top: -10,
                          right: -10,
                          child: Icon(Icons.wifi, color: Color(0xFF00B4D8), size: 24),
                        )
                      ],
                    ),
                    const SizedBox(width: 12),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.headline.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        children: const [
                          TextSpan(text: "My", style: TextStyle(color: Color(0xFF003F9A))),
                          TextSpan(text: "Card", style: TextStyle(color: Color(0xFF003F9A))),
                          TextSpan(text: "Share", style: TextStyle(color: Color(0xFF00B4D8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final data = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: data["align"] == TextAlign.start 
                            ? CrossAxisAlignment.start 
                            : CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: index == 0 
                                  ? _buildMockCard1() 
                                  : index == 1 
                                      ? _buildMockCard2() 
                                      : _buildMockCircles(),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: RichText(
                              textAlign: data["align"],
                              text: TextSpan(
                                style: AppTextStyles.headline.copyWith(
                                  fontSize: 32,
                                  height: 1.2,
                                  color: const Color(0xFF2C3333),
                                  fontWeight: FontWeight.w800,
                                ),
                                children: [
                                  TextSpan(text: data["title_black"]),
                                  TextSpan(
                                    text: data["title_blue"],
                                    style: const TextStyle(
                                      color: Color(0xFF2988FA), 
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _onboardingData.length,
                        (index) => buildDot(index, context),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_currentPage == _onboardingData.length - 1) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF2C3333),
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: _currentPage == index ? 32 : 16,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.white : const Color(0x66FFFFFF),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildMockCard1() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(0.3)
        ..rotateY(-0.25)
        ..rotateZ(-0.4),
      alignment: FractionalOffset.center,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-50, 75),
            child: Opacity(
              opacity: 0.1,
              child: _buildCardContent(),
            ),
          ),
          Transform.translate(
            offset: const Offset(-25, 38),
            child: Opacity(
              opacity: 0.4,
              child: _buildCardContent(),
            ),
          ),
          _buildCardContent(),
        ],
      ),
    );
  }

  Widget _buildMockCard2() {
    return _buildCardContent();
  }

  Widget _buildCardContent() {
    return Container(
      width: 250,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color(0xFF2988FA),
                  padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 4),
                      const Text("v-ray", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 3),
                          Text("For", style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.w600)),
                          Text("3ds Max", style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: -30,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Alex Johnson", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2C3333))),
                  SizedBox(height: 1),
                  Text("Marketing Manager", style: TextStyle(color: Color(0xFF555555), fontSize: 10)),
                  Text("Compliforce Pvt Ltd", style: TextStyle(color: Color(0xFF888888), fontSize: 9)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Headline", style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 8)),
                  SizedBox(height: 2),
                  Text(
                    "Helping businesses build meaningful connections through smarter digital experiences.",
                    style: TextStyle(color: Color(0xFF444444), fontSize: 9, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildContactRow(Icons.email, "alexjohnson@gmail.com", "Personal"),
                  _buildContactRow(Icons.email, "alexjohnson@compliforce.com", "Work"),
                  _buildContactRow(Icons.phone, "+91 9876543210", "Personal"),
                  _buildContactRow(Icons.phone, "+91 9876543210", "Work"),
                  _buildContactRow(Icons.location_on, "PO Box 1234, Austin, TX 78701", "Office"),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.language, size: 10, color: Color(0xFF2988FA)),
                      SizedBox(width: 4),
                      Text("Website", style: TextStyle(color: Color(0xFF2988FA), fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xFFE8F4FF),
            child: Icon(icon, size: 10, color: const Color(0xFF2988FA)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF333333), fontSize: 9, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(subtitle, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 7)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockCircles() {
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x4DFFFFFF),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: _buildIconCircle(Icons.qr_code_2, "QR", 100),
          ),
          Positioned(
            top: 40,
            right: 40,
            child: _buildIconCircle(Icons.nfc, "NFC", 80),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: _buildIconCircle(Icons.email, "Email", 90),
          ),
          Positioned(
            bottom: 60,
            left: 60,
            child: _buildIconCircle(Icons.link, "Link", 70),
          ),
        ],
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, String label, double size) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFF2988FA),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3333))),
      ],
    );
  }
}
