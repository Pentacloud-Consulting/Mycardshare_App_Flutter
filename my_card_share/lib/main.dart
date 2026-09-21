import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'features/auth/font style/font_style.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppFontStyle.init();
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}
