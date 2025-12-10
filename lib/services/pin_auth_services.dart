// lib/services/pin_auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinAuthService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';

  static Future<bool> hasPin() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null;
  }

  static Future<bool> validatePin(String inputPin) async {
    final storedPin = await _storage.read(key: _pinKey);
    return storedPin == inputPin;
  }

  static Future<void> setPin(String newPin) async {
    await _storage.write(key: _pinKey, value: newPin);
  }

  static Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
  }
}
