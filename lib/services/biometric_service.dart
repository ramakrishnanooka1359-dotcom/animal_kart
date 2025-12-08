import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final _auth = LocalAuthentication();
  static DateTime? _lastAuthAttempt;
  static const Duration _authCooldown = Duration(milliseconds: 500);

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    // Prevent multiple rapid authentication attempts
    final now = DateTime.now();
    if (_lastAuthAttempt != null) {
      final diff = now.difference(_lastAuthAttempt!);
      if (diff < _authCooldown) {
        return false;
      }
    }
    
    _lastAuthAttempt = now;
    
    try {
      // Check if device supports biometrics
      final isAvailable = await _auth.canCheckBiometrics;
      if (!isAvailable) return false;

      // Authenticate
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Verify your fingerprint to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
      );
      
      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}