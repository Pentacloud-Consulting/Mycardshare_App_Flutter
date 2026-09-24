// firebase_options.dart
// Updated with real credentials from google-services.json
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // ── Android ────────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDdd6s5MsYSk-TRQyG-NbhVuvebSyIKbUk',
    appId: '1:943022881240:android:5a64941dbeec389b2e5aad',
    messagingSenderId: '943022881240',
    projectId: 'business-card-64459',
    storageBucket: 'business-card-64459.firebasestorage.app',
  );

  // ── iOS ────────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdd6s5MsYSk-TRQyG-NbhVuvebSyIKbUk',
    appId: '1:943022881240:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '943022881240',
    projectId: 'business-card-64459',
    storageBucket: 'business-card-64459.firebasestorage.app',
    iosClientId: '943022881240-uab2qbq06cpoc7vb3ur2ioc60su9dag0.apps.googleusercontent.com',
    iosBundleId: 'com.pentacloud.mycardshare',
  );

  // ── Web ─────────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDdd6s5MsYSk-TRQyG-NbhVuvebSyIKbUk',
    appId: '1:943022881240:web:YOUR_WEB_APP_ID',
    messagingSenderId: '943022881240',
    projectId: 'business-card-64459',
    storageBucket: 'business-card-64459.firebasestorage.app',
    authDomain: 'business-card-64459.firebaseapp.com',
  );
}
