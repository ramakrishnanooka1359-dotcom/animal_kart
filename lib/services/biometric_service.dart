// // lib/services/biometric_service.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:animal_kart_demo2/services/pin_auth_services.dart';

// class BiometricService {
//   static bool isUnlocked = false;
//   static final _auth = LocalAuthentication();

//   // ... existing methods ...

//   static Future<bool> authenticate({bool allowPinFallback = true}) async {
//     try {
//       // First try biometrics
//       final hasBiometric = await _auth.canCheckBiometrics;
//       if (hasBiometric) {
//         final authenticated = await _auth.authenticate(
//           localizedReason: 'Authenticate to access your account',
//           options: const AuthenticationOptions(
//             stickyAuth: true,
//             biometricOnly: true,
//           ),
//         );

//         if (authenticated) {
//           isUnlocked = true;
//           return true;
//         }
//       }

//       // If biometric fails or not available, try PIN if allowed
//       if (allowPinFallback && await PinAuthService.hasPin()) {
//         // We'll handle PIN entry in the UI
//         return false;
//       }

//       return false;
//     } on PlatformException catch (e) {
//       debugPrint('Biometric auth error: $e');
//       return false;
//     }
//   }
//   // void updateLockStatus(){

//   // }

//   static void unlock() => isUnlocked = true;
//   static void lock() => isUnlocked = false;
// }
// lib/services/biometric_service.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static bool isUnlocked = false;

  static Future<bool> get isDeviceSupported async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final isSupported = await isDeviceSupported;
      if (!isSupported) {
        isUnlocked = true;
        return true;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        isUnlocked = true;
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      debugPrint('Error: ${e.message}');
      return false;
    }
  }

  static void unlock() => isUnlocked = true;
  static void lock() => isUnlocked = false;
}
