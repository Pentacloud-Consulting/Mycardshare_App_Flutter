import 'package:flutter/material.dart';

void showPremiumBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PremiumBottomSheet(),
  );
}

class PremiumBottomSheet extends StatefulWidget {
  const PremiumBottomSheet({super.key});

  @override
  State<PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<PremiumBottomSheet> {
  int _selectedPlan = 1; // 0 = Monthly, 1 = Yearly, 2 = Lifetime

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80), 
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Background
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF281F34), Color(0xFF1E1729)], // Dark purplish grey
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("👑", style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text(
                  "Go Premium",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Unlock powerful tools designed to help you connect,\nshare, and grow.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Features
                _buildFeatureRow("Unlimited cards"),
                _buildFeatureRow("Remove Mycardshare branding"),
                _buildFeatureRow("Advanced Analytics"),
                _buildFeatureRow("AI card scanner"),
                _buildFeatureRow("Premium templates"),
                
                const SizedBox(height: 32),
                
                // Pricing Cards
                Row(
                  children: [
                    Expanded(child: _buildPricingCard(0, "Monthly", "89 AED", null)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPricingCard(1, "Yearly", "899 AED", "Save 50%")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildPricingCard(2, "Lifetime", "1599 AED", null)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Upgrade Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B00FF), // Bright purple
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Upgrade to Premium Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Bottom padding for safe area
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
          
          // Close Button
          Positioned(
            top: -10,
            right: 180,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF), // Semi-transparent white
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFFFCA311), size: 18), // Orange check
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(int index, String title, String price, String? badge) {
    final isSelected = _selectedPlan == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = index;
        });
      },
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A2B7C) : const Color(0xFF423B53), // Slightly brighter for selected
          border: Border.all(
            color: isSelected ? const Color(0xFF9D4EDD) : Colors.transparent, // Purple outline
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD1C8E1) : Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFFFCA311), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    badge,
                    style: const TextStyle(
                      color: Color(0xFFFCA311),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
