import 'package:flutter/material.dart';
import 'vault_screen.dart';

export 'vault_screen.dart';
export 'widgets/vault_header.dart';
export 'widgets/vault_search_bar.dart';
export 'widgets/vault_filter_pills.dart';
export 'widgets/vault_category.dart';
export 'widgets/vault_camera.dart';
export 'widgets/vault_contact_card.dart';

class IndividualVaultScreen extends StatelessWidget {
  const IndividualVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const VaultScreen();
  }
}
