import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Call this once at app startup (in main.dart) before runApp().
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
