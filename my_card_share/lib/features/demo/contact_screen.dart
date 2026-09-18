import 'package:flutter/material.dart';
import '../../widgets/mobile_top_bar.dart';
import '../../widgets/mobile_bottom_buttons.dart';
import '../../widgets/main_menu_dialog.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenuDrawer(),
      extendBody: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FBFD), Color(0xFFE2F0FD), Color(0xFF90C4FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const MobileTopBar(title: 'Contacts'),
                        const SizedBox(height: 24),
                        
                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8ECEF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: Color(0xFF888888)),
                              hintText: "Search",
                              hintStyle: TextStyle(color: Color(0xFF888888)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const Text(
                          "Recents",
                          style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        
                        _buildContactCard("Alex Johnson", "Marketing Manager", "Compliforce Pvt Ltd"),
                        _buildContactCard("Alex Johnson", "Marketing Manager", "Compliforce Pvt Ltd"),
                      ],
                    ),
                  ),
                ),
              ),

              // Custom Bottom Navigation
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: MobileBottomButtons(activeIndex: 3), // Contact is index 3
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(String name, String role, String company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.grey.shade400, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF2C3333))),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                Text(company, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF2C3333)),
        ],
      ),
    );
  }
}
