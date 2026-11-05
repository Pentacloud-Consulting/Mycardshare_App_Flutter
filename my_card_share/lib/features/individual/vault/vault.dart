import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'vault_screen.dart' as ind_vault;
import '../../employee/vault/vault_screen.dart' as emp_vault;

export 'vault_screen.dart';
export 'widgets/vault_header.dart';
export 'widgets/vault_search_bar.dart';
export 'widgets/vault_filter_pills.dart';
export 'widgets/vault_category.dart';
export 'widgets/vault_camera.dart';
export 'widgets/vault_contact_card.dart';

class IndividualVaultScreen extends ConsumerWidget {
  const IndividualVaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role.toLowerCase();
    if (role == 'employee') {
      return const emp_vault.VaultScreen();
    }
    return const ind_vault.VaultScreen();
  }
}


