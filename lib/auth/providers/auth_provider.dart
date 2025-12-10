
import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:animal_kart_demo2/auth/models/whatsapp_otp_response.dart';
import 'package:animal_kart_demo2/network/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:shared_preferences/shared_preferences.dart';

final authProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(),
);

class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  
  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  
  WhatsappOtpResponse? _whatsappOtpResponse;
  WhatsappOtpResponse? get whatsappOtpResponse => _whatsappOtpResponse;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  
  // LOGOUT
 
  Future<void> logout() async {
  try {
    _setLoading(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    _userProfile = null;
    _whatsappOtpResponse = null;

    notifyListeners();
  } catch (e) {
    debugPrint('Error during logout: $e');
    rethrow;
  } finally {
    _setLoading(false);
  }
}


  //UPDATE USER DATA API
Future<UserModel?> updateUserdata({
  required String userId,
  Map<String, dynamic>? extraFields,
}) async {
  _isLoading = true;
  notifyListeners();

  try {
    if (userId.isEmpty) {
      throw ArgumentError("Mobile number is required");
    }

    final payload = <String, dynamic>{};

    if (extraFields != null && extraFields.isNotEmpty) {
      payload.addAll(extraFields);
    }

    final user = await ApiServices.updateUserProfile(
      mobile: userId,
      body: payload,
    );

    return user;
  } catch (e) {
    debugPrint("UPDATE ERROR: $e");
    return null;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}



  
  //SEND WHATSAPP OTP
 
  Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
    _setLoading(true);

    try {
      final response = await ApiServices.sendWhatsappOtp(phone);

      if (response != null) {
        _whatsappOtpResponse = response;

        if (response.user != null) {
          _userProfile = response.user;
        }
      }

      return response;
    } catch (e) {
      debugPrint("Send OTP failed: $e");
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ============================
 //VERIFY OTP LOCALLY
  // ============================
  bool verifyWhatsappOtpLocal(String enteredOtp) {
    if (_whatsappOtpResponse == null) return false;
    return _whatsappOtpResponse!.otp == enteredOtp;
  }


  // UPDATE PROFILE LOCALLY

  void updateProfile(UserModel newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }

  // ============================
  // ✅ CLEAR SESSION
  // ============================
  void clearSession() {
    _userProfile = null;
    _whatsappOtpResponse = null;
    notifyListeners();
  }
}
