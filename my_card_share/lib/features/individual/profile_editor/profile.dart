import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../profile/profile_view_screen.dart' as ind_profile;
import '../../employee/profile/profile_view_screen.dart' as emp_profile;

export '../profile/profile_editor_screen.dart';
export '../profile/profile_view_screen.dart';

class IndividualProfileEditorScreen extends ConsumerWidget {
  const IndividualProfileEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role.toLowerCase();
    if (role == 'employee') {
      return const emp_profile.ProfileViewScreen();
    }
    return const ind_profile.ProfileViewScreen();
  }
}


