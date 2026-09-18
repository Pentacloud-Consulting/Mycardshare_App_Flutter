import 'package:flutter/material.dart';
import '../../../features/Nav/portal_bottom_nav.dart';
import '../../../features/Nav/portal_top_nav.dart';
import '../../../features/individual/home/View My card/home.dart';

class IndividualCardScreen extends StatelessWidget {
  final String? slug;
  final bool showBottomNav;

  const IndividualCardScreen({
    super.key,
    this.slug,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final slugName = slug ?? '';
    final name = slugName.contains('alex') ? "Alex Stanton" : "Sarah Khan";
    final role = slugName.contains('alex') ? "Product Designer" : "Marketing Manager";
    final company = "Acme Realty Group";

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

                  // Image 5: Save Contact, Secondary Buttons & Center QR Button (Image 2)
                  CardFooterActions(name: name),

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
