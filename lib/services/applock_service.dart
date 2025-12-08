import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService {
  static const String _lastActiveTimeKey = 'last_active_time';
  static const String _isLockedKey = 'is_locked';
  static const int _lockTimeoutSeconds = 0; // Lock immediately when app goes to background
  static bool _isChecking = false;
  static Completer<void>? _currentCheck;

  static Future<void> saveLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastActiveTimeKey, now);
    await prefs.setBool(_isLockedKey, false); // Mark as not locked
  }

  // Check if app should be locked based on timeout
  static Future<bool> shouldLockApp() async {
    // If already checking, return the same result
    if (_isChecking && _currentCheck != null) {
      await _currentCheck!.future;
      // Return the cached result after waiting
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLockedKey) ?? false;
    }
    
    _isChecking = true;
    _currentCheck = Completer<void>();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we're already in locked state
      final isCurrentlyLocked = prefs.getBool(_isLockedKey) ?? false;
      if (isCurrentlyLocked) {
        // Already locked, don't show dialog again
        return true;
      }
      
      final lastActiveTime = prefs.getInt(_lastActiveTimeKey);
      
      if (lastActiveTime == null) {
        // First time or never saved, mark as locked and return true
        await prefs.setBool(_isLockedKey, true);
        return true;
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedSeconds = (now - lastActiveTime) / 1000;
      
      final shouldLock = elapsedSeconds >= _lockTimeoutSeconds;
      if (shouldLock) {
        await prefs.setBool(_isLockedKey, true);
      }
      return shouldLock;
    } finally {
      _isChecking = false;
      _currentCheck?.complete();
      _currentCheck = null;
    }
  }

  // Clear the saved time (for logout, etc.)
  static Future<void> clearLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActiveTimeKey);
    await prefs.remove(_isLockedKey);
  }

  // Manually unlock the app (call this after successful authentication)
  static Future<void> unlockApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLockedKey, false);
  }
}