import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserToPrefs(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('userId', user.id);
  await prefs.setString('userMobile', user.mobile);
  await prefs.setString('refered_by_mobile', user.referedByMobile);
  await prefs.setString('refered_by_name', user.referedByName);
  await prefs.setString('gender', user.gender);
  await prefs.setString('email', user.email);
  await prefs.setString('full_name', user.name);
  await prefs.setString('aadharNumber', user.aadharNumber);
  
 
}

Future<UserModel?> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final id = prefs.getString('userId');
    if (id == null) return null;

    return UserModel(
      id: id,
      name: prefs.getString('full_name') ?? '',
      firstName: '',
      lastName: '',
      mobile: prefs.getString('userMobile') ?? '',
      email: prefs.getString('email') ?? '',
      verified: prefs.getBool('verified') ?? false,
      otpVerified: prefs.getBool('otp_verified') ?? false,
      isFormFilled: prefs.getBool('isFormFilled'),
      gender: prefs.getString('gender') ?? '',
      occupation: '',
      address: prefs.getString('address') ?? '',
      city: prefs.getString('city') ?? '',
      state: prefs.getString('state') ?? '',
      pincode: prefs.getString('pincode') ?? '',
      aadharNumber: prefs.getString('aadharNumber') ?? '',
      referedByMobile: prefs.getString('refered_by_mobile') ?? '',
      referedByName: prefs.getString('refered_by_name') ?? '',
      otp: '',
    );
  }

  Future<void> clearUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }