import 'package:flutter/material.dart';
import '../individual/user_view_card/scanned_profile_view_screen.dart';
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
    if (slug != null && slug!.trim().isNotEmpty) {
      return ScannedProfileViewScreen(cardSlug: slug!.trim());
    }
    return IndividualCardScreen(
      slug: slug,
      showBottomNav: showBottomNav,
    );
  }
}
