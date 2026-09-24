import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'features/auth/font style/font_style.dart';
import 'backend/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppFontStyle.init();

  // Initialize Firebase with real project credentials
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}
