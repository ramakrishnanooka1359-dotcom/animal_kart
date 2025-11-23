class UserProfile {
  final String id;
  final String? name;
  final String? firstName;
  final String? familyName;
  final String? referralType;
  final bool? verified;
  final String? email;
  final String? address;
  final String? phone; // canonical phone (E.164 preferred)
  final String? mobile; // raw mobile from API
  final String? city;
  final String? state;
  final String? pincode;
  final String? occupation;
  final String? incomeLevel;
  final int? familySize;
  final Map<String, dynamic>? customFields;

  // New fields from your API
  final String? aadhaarNumber;
  final String? gender;
  final String? deviceModel;
  final String? deviceId;
  final bool? isFormFilled;
  final String? dob; // keep raw string (can be parsed)
  final String? aadharFrontImageUrl;
  final String? aadharBackImageUrl;

  UserProfile({
    required this.id,
    this.name,
    this.firstName,
    this.familyName,
    this.referralType,
    this.verified,
    this.email,
    this.address,
    this.phone,
    this.mobile,
    this.city,
    this.state,
    this.pincode,
    this.occupation,
    this.incomeLevel,
    this.familySize,
    this.customFields,
    this.aadhaarNumber,
    this.gender,
    this.deviceModel,
    this.deviceId,
    this.isFormFilled,
    this.dob,
    this.aadharBackImageUrl,
    this.aadharFrontImageUrl,
  });

  /// ------------------------------
  /// FROM JSON (API → Model)
  /// ------------------------------
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      firstName: json['first_name'] as String?,
      familyName: json['family_name'] as String?,
      referralType: json['referral_type'] as String?,
      verified: json['verified'] is bool ? json['verified'] as bool : null,
      email: json['email'] as String?,
      address: json['address'] as String?,
      // prefer normalized "phone", fallback to "mobile"
      phone: (json['phone'] as String?) ?? (json['mobile'] as String?),
      mobile: json['mobile'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      occupation: json['occupation'] as String?,
      incomeLevel: json['income_level'] as String?,
      familySize: json['family_size'] is int
          ? json['family_size'] as int
          : null,
      customFields: (json['custom_fields'] as Map?)?.cast<String, dynamic>(),
      // new fields
      aadhaarNumber: json['addhar_number'] ?? json['aadhaar_number'] as String?,
      gender: json['gender'] as String?,
      deviceModel: json['device_model'] as String?,
      deviceId: json['device_id'] as String?,
      isFormFilled: json['isFormFilled'] is bool
          ? json['isFormFilled'] as bool
          : (json['isFormFilled'] == 'true' || json['isFormFilled'] == true),
      dob: json['dob'] as String?,
    );
  }

  /// ------------------------------
  /// TO JSON (Model → API full object)
  /// ------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'family_name': familyName,
      'referral_type': referralType,
      'verified': verified,
      'email': email,
      'address': address,
      'phone': phone,
      'mobile': mobile,
      'city': city,
      'state': state,
      'pincode': pincode,
      'occupation': occupation,
      'income_level': incomeLevel,
      'family_size': familySize,
      'custom_fields': customFields,
      'addhar_number': aadhaarNumber,
      'gender': gender,
      'device_model': deviceModel,
      'device_id': deviceId,
      'isFormFilled': isFormFilled,
      'dob': dob,
    }..removeWhere((k, v) => v == null);
  }

  /// ------------------------------
  /// PARTIAL UPDATE (Model → Update fields)
  /// ------------------------------
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};

    void add(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    add('name', name);
    add('first_name', firstName);
    add('family_name', familyName);
    add('referral_type', referralType);
    add('verified', verified);
    add('email', email);
    add('address', address);
    add('phone', phone);
    add('mobile', mobile);
    add('city', city);
    add('state', state);
    add('pincode', pincode);
    add('occupation', occupation);
    add('income_level', incomeLevel);
    add('family_size', familySize);
    add('custom_fields', customFields);

    // new fields
    add('addhar_number', aadhaarNumber);
    add('gender', gender);
    add('device_model', deviceModel);
    add('device_id', deviceId);
    add('isFormFilled', isFormFilled);
    add('dob', dob);
    add('aadhar_front_image_url', aadharFrontImageUrl);
    add("aadhar_back_image_url", aadharBackImageUrl);

    return data;
  }

  /// ------------------------------
  /// COPY WITH (for updating local state)
  /// ------------------------------
  UserProfile copyWith({
    String? name,
    String? firstName,
    String? familyName,
    String? referralType,
    bool? verified,
    String? email,
    String? address,
    String? phone,
    String? mobile,
    String? city,
    String? state,
    String? pincode,
    String? occupation,
    String? incomeLevel,
    int? familySize,
    Map<String, dynamic>? customFields,
    String? aadhaarNumber,
    String? gender,
    String? deviceModel,
    String? deviceId,
    bool? isFormFilled,
    String? dob,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      familyName: familyName ?? this.familyName,
      referralType: referralType ?? this.referralType,
      verified: verified ?? this.verified,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      occupation: occupation ?? this.occupation,
      incomeLevel: incomeLevel ?? this.incomeLevel,
      familySize: familySize ?? this.familySize,
      customFields: customFields ?? this.customFields,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      gender: gender ?? this.gender,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceId: deviceId ?? this.deviceId,
      isFormFilled: isFormFilled ?? this.isFormFilled,
      dob: dob ?? this.dob,
      aadharBackImageUrl: aadhaarBackUrl ?? this.aadharBackImageUrl,
      aadharFrontImageUrl: aadhaarFrontUrl ?? this.aadharFrontImageUrl,
    );
  }

  /// ------------------------------
  /// Helper: parse dob to DateTime (best-effort)
  /// ------------------------------
  DateTime? get dobAsDate {
    if (dob == null) return null;
    try {
      return DateTime.parse(dob!);
    } catch (_) {
      // try common mm-dd-yyyy or dd-mm-yyyy variations
      final parts = dob!.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        try {
          // attempt to detect common formats
          if (parts[0].length == 4) {
            // yyyy-mm-dd
            return DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          } else {
            // assume mm-dd-yyyy or dd-mm-yyyy -> fallback to mm-dd-yyyy
            return DateTime(
              int.parse(parts[2]),
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
          }
        } catch (e) {
          return null;
        }
      }
      return null;
    }
  }
}
