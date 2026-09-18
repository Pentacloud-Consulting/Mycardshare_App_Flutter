import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/mobile_bottom_buttons.dart';
import '../../widgets/mobile_top_bar.dart';
import '../../widgets/main_menu_dialog.dart';
import '../../widgets/qr_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MainMenuDrawer(),
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FBFE),
              Color(0xFFE6F3FF),
              Color(0xFF8AC7FF),
              Color(0xFF2988FA),
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Scrollable Content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const MobileTopBar(),
                        const SizedBox(height: 24),
                        _buildMyCardHeader(context),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.push('/view_card'),
                          child: _buildCard(),
                        ),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Custom Bottom Navigation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: const MobileBottomButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCardHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("My Card", style: TextStyle(fontSize: 14, color: Color(0xFF2C3333), fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: () => context.push('/view_card'),
          child: Row(
            children: const [
              Icon(Icons.edit_outlined, size: 14, color: Color(0xFF888888)),
              SizedBox(width: 4),
              Text("Edit", style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Blue Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFF2988FA),
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                      const SizedBox(width: 6),
                      const Text("v-ray", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 4),
                          Text("For", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                          Text("3ds Max", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Profile Info Section
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Alex Johnson", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2C3333))),
                    const SizedBox(height: 2),
                    const Text("Marketing Manager", style: TextStyle(color: Color(0xFF555555), fontSize: 13)),
                    const Text("Compliforce Pvt Ltd", style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
                    const SizedBox(height: 16),
                    const Text("Headline", style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 10)),
                    const SizedBox(height: 4),
                    const Text(
                      "Helping businesses build meaningful connections through smarter digital experiences.",
                      style: TextStyle(color: Color(0xFF444444), fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    // Contact Cards
                    _buildContactCardRow(Icons.email, "alexjohnson@gmail.com", "Personal"),
                    _buildContactCardRow(Icons.phone, "+91 9876543210", "Personal"),
                    _buildContactCardRow(Icons.location_on, "PO Box 1234, Austin, TX 78701", "Office"),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _buildSquareContactCard(Icons.language, "Website")),
                        const SizedBox(width: 10),
                        Expanded(child: _buildSquareContactCard(Icons.chat_bubble_outline, "Whatsapp")), 
                        const SizedBox(width: 10),
                        Expanded(child: _buildSquareContactCard(Icons.facebook, "Facebook")),
                      ],
                    ),
                  ],
                ),
              ),
              // Profile Picture overlapping the boundary
              Positioned(
                right: 20,
                top: -50,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCardRow(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F4FF),
            child: Icon(icon, size: 18, color: const Color(0xFF2988FA)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF333333), fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                Text(subtitle, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareContactCard(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2988FA)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPillButton(context, Icons.qr_code_2, "QR Code", onTap: () => showQRBottomSheet(context)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPillButton(context, Icons.share_outlined, "Share Card"),
        ),
      ],
    );
  }

  Widget _buildPillButton(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2988FA)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Color(0xFF2988FA), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
