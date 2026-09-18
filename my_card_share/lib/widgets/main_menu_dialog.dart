import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenuDrawer extends StatelessWidget {
  const MainMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: const Color(0xFF1C1C1E), // Dark background matching Image 2
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Alex Johnson",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Marketing Manager",
                          style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
                        ),
                        Text(
                          "Compliforce Pvt Ltd",
                          style: TextStyle(color: Color(0xFF888888), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Closes the drawer
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0x26FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 30),

              // Premium Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B00D7), Color(0xFF4A00A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("👑", style: TextStyle(fontSize: 28)), // Crown icon placeholder
                    SizedBox(height: 12),
                    Text(
                      "Upgrade to Premium",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Unlock powerful tools designed to help you connect, share, and grow.",
                      style: TextStyle(color: Color(0xFFE0C9FF), fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Menu List Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E), // Slightly lighter grey for the list background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildMenuItem("Languages", Icons.chevron_right, onTap: () {
                      Navigator.pop(context);
                      context.push('/language');
                    }),
                    _buildDivider(),
                    _buildMenuItem("Dark theme", null, trailing: Switch(
                      value: true, 
                      onChanged: (val) {},
                      activeThumbColor: Colors.white,
                      activeTrackColor: Colors.grey[600],
                    )),
                    _buildDivider(),
                    _buildMenuItem("Backup & Restore", Icons.chevron_right, onTap: () {
                      Navigator.pop(context);
                      context.push('/backup_restore');
                    }),
                    _buildDivider(),
                    _buildMenuItem("Export Data", Icons.chevron_right, onTap: () {
                      Navigator.pop(context);
                      context.push('/export_data');
                    }),
                    _buildDivider(),
                    _buildMenuItem("Logout", Icons.chevron_right, onTap: () {
                      Navigator.pop(context);
                      context.go('/login');
                    }),
                  ],
                ),
              ),

              const Spacer(),

              // Bottom Logo
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wifi_tethering, color: Color(0xFF2988FA), size: 36),
                      SizedBox(width: 8),
                      Text(
                        "MyCardShare",
                        style: TextStyle(color: Color(0xFF2988FA), fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Version 1.0",
                    style: TextStyle(color: Color(0xFF777777), fontSize: 12),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData? trailingIcon, {Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            if (trailing != null) trailing
            else if (trailingIcon != null) Icon(trailingIcon, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0x1AFFFFFF),
      margin: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
