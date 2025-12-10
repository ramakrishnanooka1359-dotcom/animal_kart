class UserModel {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;

  final bool verified;
  final bool otpVerified;
  final bool? isFormFilled;

  final String gender;
  final String occupation;
  final String address;
  final String city;
  final String state;
  final String pincode;

  final int aadharNumber;

  final String referedByMobile;
  final String referedByName;

  final String otp;

  UserModel({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.verified,
    required this.otpVerified,
    required this.isFormFilled,
    required this.gender,
    required this.occupation,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.aadharNumber,
    required this.referedByMobile,
    required this.referedByName,
    required this.otp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',

      verified: json['verified'] ?? false,
      otpVerified: json['otp_verified'] ?? false,
      isFormFilled: json['isFormFilled'],

      gender: json['gender'] ?? '',
      occupation: json['occupation'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      aadharNumber: int.parse(json['aadhar_number'].toString()),
      referedByMobile: json['refered_by_mobile'] ?? '',
      referedByName: json['refered_by_name'] ?? '',

      otp: json['otp'] ?? '',
    );
  }
}
