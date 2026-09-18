import 'package:flutter/material.dart';
import '../../services/Individual/view my card/public_card_screen.dart';

class PublicCardScreen extends StatelessWidget {
  final String? slug;
  final bool showBottomNav;

  const PublicCardScreen({
    super.key,
    this.slug,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    // In the future, you will fetch data here to determine if this is an 
    // Individual, Enterprise, etc. card.
    // For now, we hardcode it to fetch the Individual card UI.
    return IndividualCardScreen(
      slug: slug,
      showBottomNav: showBottomNav,
    );
  }
}
