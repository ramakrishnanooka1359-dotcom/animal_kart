// This is a template. You need to generate the actual file using Firebase CLI.
// Run the following commands in your terminal:
// 1. flutter pub add firebase_core
// 2. dart pub global activate flutterfire_cli
// 3. flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Since we're targeting Android, we'll use the Android configuration
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_AUTH_DOMAIN',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVTVvY8KxJ87tRFS7z3Ppy5P7sU22_pWY',
    appId: '1:72281267936:android:1a82dda491c756a1dc3a85',
    messagingSenderId: '72281267936',
    projectId: 'animalkart-559c3',
    storageBucket: 'animalkart-559c3.firebasestorage.app',
  );
}
