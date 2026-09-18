import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/qr_bottom_sheet.dart';

class ViewCardScreen extends StatelessWidget {
  const ViewCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FBFD), Color(0xFFCBE2FA), Color(0xFF3892F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8ECEF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Color(0xFF2C3333), size: 20),
                      ),
                    ),
                    const Text("View Card Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3333))),
                    Row(
                      children: const [
                        Icon(Icons.edit_outlined, size: 16, color: Color(0xFF888888)),
                        SizedBox(width: 4),
                        Text("Edit", style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                      ],
                    )
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2988FA),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 32),
                                        const SizedBox(width: 8),
                                        const Text("v-ray", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 4),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: const [
                                            Text("For", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                            Text("3ds Max", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      const Text("Alex Johnson", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3333))),
                                      const SizedBox(height: 4),
                                      const Text("Marketing Manager", style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                                      const Text("Compliforce Pvt Ltd", style: TextStyle(fontSize: 14, color: Color(0xFF888888))),
                                      const SizedBox(height: 20),
                                      
                                      const Text("Headline", style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Helping businesses build meaningful connections through smarter digital experiences.",
                                        style: TextStyle(fontSize: 13, color: Color(0xFF2C3333), height: 1.4),
                                      ),
                                      const SizedBox(height: 20),

                                      _buildContactItem(Icons.email, "alexjohnson@gmail.com", "Personal"),
                                      _buildContactItem(Icons.email, "alexjohnson@compliforce.com", "Work"),
                                      _buildContactItem(Icons.phone, "+91 9876543210", "Personal"),
                                      _buildContactItem(Icons.phone, "+91 9876543210", "Work"),
                                      _buildContactItem(Icons.location_on, "PO Box 1234, Austin, TX 78701", "Office"),

                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(child: _buildSocialButton(Icons.language, "Website")),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildSocialButton(Icons.chat_bubble_outline, "Whatsapp")),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildSocialButton(Icons.facebook, "Facebook")),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            Positioned(
                              top: 70,
                              right: 24,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                                ),
                                child: const CircleAvatar(
                                  backgroundColor: Color(0xFFE8ECEF),
                                  child: Icon(Icons.person, size: 60, color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(context, Icons.qr_code, "QR Code", onTap: () => showQRBottomSheet(context)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(context, Icons.share, "Share Card"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2C3333),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Save Contact",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0FD),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2988FA), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF2C3333), fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2988FA), size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Color(0xFF2C3333), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2988FA), size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF2988FA), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
