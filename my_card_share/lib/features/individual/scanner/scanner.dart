import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import 'scanner_screen.dart' as ind_scanner;
import '../../employee/scanner/scanner_screen.dart' as emp_scanner;

class IndividualScannerScreen extends ConsumerWidget {
  const IndividualScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).role.toLowerCase();
    if (role == 'employee') {
      return const emp_scanner.ScannerScreen();
    }
    return const ind_scanner.ScannerScreen();
  }
}


