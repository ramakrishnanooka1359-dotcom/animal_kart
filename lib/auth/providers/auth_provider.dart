import 'dart:convert';
import 'dart:io';
import 'package:animal_kart_demo2/auth/models/user_details.dart';
import 'package:animal_kart_demo2/network/api_services.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

final authProvider = ChangeNotifierProvider<AuthController>(
  (ref) => AuthController(),
);

class AuthController extends ChangeNotifier {
  //setters
  bool _isLoading = false;

  UserProfile? _userProfile;

  //getters
  bool get isLoading => _isLoading;
  UserProfile? get userProfile => _userProfile;

  // Logout user
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear user profile
      _userProfile = null;

      // Clear any stored tokens or user data
      // Add any additional cleanup code here
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // verfiy user
  Future<bool> verifyUser(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      final deviceDetails = await ApiServices.fetchDeviceDetails();
      final response = await http.post(
        Uri.parse("${AppConstants.apiUrl}/users/verify"),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: jsonEncode({
          'mobile': phone,
          'device_id': deviceDetails.id,
          'device_model': deviceDetails.model,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        final bool isSuccess = data["status"] == "success";

        if (isSuccess && data["user"] != null) {
          _userProfile = UserProfile.fromJson(
            data["user"] as Map<String, dynamic>,
          );
          print(_userProfile);
        }

        return isSuccess;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserdata({
    String? userId,
    UserProfile? profile,
    Map<String, dynamic>? extraFields,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final targetUserId = userId ?? profile?.id;
      if (targetUserId == null || targetUserId.isEmpty) {
        throw ArgumentError('userId or profile.id must be provided');
      }

      final payload = <String, dynamic>{};

      if (profile != null) {
        payload.addAll(profile.toUpdateJson());
      }

      if (extraFields != null && extraFields.isNotEmpty) {
        payload.addAll(extraFields);
      }

      final response = await http.put(
        Uri.parse("${AppConstants.apiUrl}/users/id/$targetUserId"),
        headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        final bool isSuccess = data["status"] == "success";

        // Update local user profile if successful
        if (isSuccess && data["user"] != null) {
          _userProfile = UserProfile.fromJson(
            data["user"] as Map<String, dynamic>,
          );
        }

        return isSuccess;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile locally
  void updateProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    notifyListeners();
  }
}
