// firebase_options.dart
// Updated with real credentials from google-services.json for mycardshare-23c8d
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

  // ── Android ──────────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASPWs2Q_ICZ-U_we5t8a3RPxNEbzXR1nQ',
    appId: '1:938552190532:android:f188ca9827fd1d3f2cfe11',
    messagingSenderId: '938552190532',
    projectId: 'mycardshare-23c8d',
    storageBucket: 'mycardshare-23c8d.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyASPWs2Q_ICZ-U_we5t8a3RPxNEbzXR1nQ',
    appId: '1:938552190532:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '938552190532',
    projectId: 'mycardshare-23c8d',
    storageBucket: 'mycardshare-23c8d.firebasestorage.app',
    iosBundleId: 'com.pentacloud.mycardshare',
  );

  // ── Web ──────────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASPWs2Q_ICZ-U_we5t8a3RPxNEbzXR1nQ',
    appId: '1:938552190532:web:f188ca9827fd1d3f2cfe11',
    messagingSenderId: '938552190532',
    projectId: 'mycardshare-23c8d',
    storageBucket: 'mycardshare-23c8d.firebasestorage.app',
    authDomain: 'mycardshare-23c8d.firebaseapp.com',
  );
}
