import 'dart:ui';
import 'package:flutter/material.dart';

void showQRBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QRBottomSheet(),
  );
}

class QRBottomSheet extends StatelessWidget {
  const QRBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232528).withValues(alpha: 0.8), // Glassy dark background matching Image 2
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: "My QR" and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My QR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF), // Transparent white
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // QR Code Container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.qr_code_2, size: 180, color: Colors.black), // Using icon placeholder for QR
          ),
          const SizedBox(height: 24),
          
          const Text(
            "Point your camera to\nreceive the card",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons: Copy, Share, Download
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconBtn(Icons.copy),
              const SizedBox(width: 16),
              _buildIconBtn(Icons.share),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined, color: Colors.white, size: 20),
                  label: const Text("Download", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3892F7), // Blue button
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 32),
          
          // Or Share with
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0x33FFFFFF))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Or Share with", style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 12)),
              ),
              Expanded(child: Divider(color: Color(0x33FFFFFF))),
            ],
          ),
          const SizedBox(height: 24),
          
          // Social Icons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialCircle(Icons.chat_bubble_rounded, Colors.green), // Whatsapp
              _buildSocialCircle(Icons.mail, Colors.redAccent), // Gmail
              _buildSocialCircle(Icons.facebook, Colors.blue), // Facebook
              _buildSocialCircle(Icons.email, Colors.grey), // Email
              _buildSocialCircle(Icons.message, Colors.white), // SMS
            ],
          ),
          const SizedBox(height: 32),
          
          // Add Card to wallet button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.wallet, color: Color(0xFF2C3333)),
              label: const Text("Add Card to wallet", style: TextStyle(color: Color(0xFF2C3333), fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          
          // Safe Area bottom spacing
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Color(0xFF2C3333), size: 20),
    );
  }

  Widget _buildSocialCircle(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF), // Transparent grey/white
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
