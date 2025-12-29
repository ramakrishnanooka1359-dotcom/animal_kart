// save_user.dart
import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserToPrefs(UserModel user) async {
  final prefs = await SharedPreferences.getInstance();

  // Store all user fields including first and last name
  await prefs.setString('userId', user.id);
  await prefs.setString('userMobile', user.mobile);
  await prefs.setString('refered_by_mobile', user.referedByMobile);
  await prefs.setString('refered_by_name', user.referedByName);
  await prefs.setString('gender', user.gender);
  await prefs.setString('email', user.email);
  await prefs.setString('full_name', user.name);
  await prefs.setString('aadharNumber', "${user.aadharNumber}");
  // ✅ Add first and last name separately
  await prefs.setString('firstName', user.firstName);
  await prefs.setString('lastName', user.lastName);
  await prefs.setDouble('coins', user.coins ?? 0.0);
  await prefs.setString('role', user.role);

  // Store verification status
  await prefs.setBool('isFormFilled', user.isFormFilled ?? false);
  await prefs.setBool('verified', user.verified);
  await prefs.setBool('otp_verified', user.otpVerified);

  // Store other user details if available
  if (user.address.isNotEmpty) {
    await prefs.setString('address', user.address);
  }
  if (user.occupation.isNotEmpty) {
    await prefs.setString('occupation', user.occupation);
  }
}

Future<UserModel?> loadUserFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();

  final id = prefs.getString('userId');
  if (id == null) return null;

  return UserModel(
    id: id,
    name: prefs.getString('full_name') ?? '',
    firstName: prefs.getString('firstName') ?? '',
    lastName: prefs.getString('lastName') ?? '',
    mobile: prefs.getString('userMobile') ?? '',
    email: prefs.getString('email') ?? '',
    verified: prefs.getBool('verified') ?? false,
    otpVerified: prefs.getBool('otp_verified') ?? false,
    isFormFilled: prefs.getBool('isFormFilled'),
    gender: prefs.getString('gender') ?? '',
    occupation: prefs.getString('occupation') ?? '',
    address: prefs.getString('address') ?? '',
    city: '', // Add if you have these fields
    state: '',
    pincode: '',
    aadharNumber: int.parse(prefs.getString('aadharNumber') ?? '0'),
    coins: prefs.getDouble('coins') ?? 0.0,
    referedByMobile: prefs.getString('refered_by_mobile') == 'null'
        ? ''
        : (prefs.getString('refered_by_mobile') ?? ''),
    referedByName: prefs.getString('refered_by_name') == 'null'
        ? ''
        : (prefs.getString('refered_by_name') ?? ''),
    role: prefs.getString('role') ?? 'Investor',
    otp: '',
  );
}
