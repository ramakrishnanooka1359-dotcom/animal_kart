import 'package:shared_preferences/shared_preferences.dart';

class ReferCoinService {
  static const _coinKey = 'user_coins';
  static const _usedReferralKey = 'used_referral';

  /// Get coins
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? 0;
  }

  /// Add coins
  static Future<void> addCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinKey) ?? 0;
    await prefs.setInt(_coinKey, current + coins);
  }

  /// Apply referral (only once)
  static Future<bool> applyReferral(String referralCode) async {
    final prefs = await SharedPreferences.getInstance();

    // Prevent multiple rewards
    if (prefs.getBool(_usedReferralKey) == true) {
      return false;
    }

    // Static validation (backend later)
    if (referralCode == "TRALAGO") {
      await addCoins(200);
      await prefs.setBool(_usedReferralKey, true);
      return true;
    }

    return false;
  }
}
