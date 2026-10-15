import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'features/auth/font style/font_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend/firebase_options.dart';
import 'backend/Offline Local Cache Re-sync/offline_sync_service.dart';
import 'backend/Global User Directory/global_auth_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppFontStyle.init();

  // Initialize Firebase with real project credentials
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Offline Queue & Delta Sync Background Listener
  OfflineSyncService.initAutoSyncListener();

  // Web Presence & Mobile Heartbeat Sync
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      GlobalAuthSyncService.syncMobileHeartbeat();
    }
  });

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}


