class UserProfile {
  final String id;
  final String? name;
  final String? referralType;
  final bool? verified;
  final String? email;
  final String? address;
  final String? phone;
  final String? city;
  final String? state;
  final String? pincode;
  final String? occupation;
  final String? incomeLevel;
  final int? familySize;
  final Map<String, dynamic>? customFields;

  UserProfile({
    required this.id,
    this.name,
    this.referralType,
    this.verified,
    this.email,
    this.address,
    this.phone,
    this.city,
    this.state,
    this.pincode,
    this.occupation,
    this.incomeLevel,
    this.familySize,
    this.customFields,
  });

  /// ------------------------------
  /// FROM JSON (API → Model)
  /// ------------------------------
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"] ?? "",
      name: json["name"],
      referralType: json["referral_type"],
      verified: json["verified"],
      email: json["email"],
      address: json["address"],
      phone: json["phone"] ?? json["mobile"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
      occupation: json["occupation"],
      incomeLevel: json["income_level"],
      familySize: json["family_size"],
      customFields: json["custom_fields"],
    );
  }

  /// ------------------------------
  /// TO JSON (Model → API full object)
  /// ------------------------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "referral_type": referralType,
      "verified": verified,
      "email": email,
      "address": address,
      "phone": phone,
      "city": city,
      "state": state,
      "pincode": pincode,
      "occupation": occupation,
      "income_level": incomeLevel,
      "family_size": familySize,
      "custom_fields": customFields,
    };
  }

  /// ------------------------------
  /// PARTIAL UPDATE (Model → Update fields)
  /// ------------------------------
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};

    void add(String key, dynamic value) {
      if (value != null) data[key] = value;
    }

    add("name", name);
    add("referral_type", referralType);
    add("verified", verified);
    add("email", email);
    add("address", address);
    add("phone", phone);
    add("city", city);
    add("state", state);
    add("pincode", pincode);
    add("occupation", occupation);
    add("income_level", incomeLevel);
    add("family_size", familySize);
    add("custom_fields", customFields);

    return data;
  }

  /// ------------------------------
  /// COPY WITH (for updating local state)
  /// ------------------------------
  UserProfile copyWith({
    String? name,
    String? referralType,
    bool? verified,
    String? email,
    String? address,
    String? phone,
    String? city,
    String? state,
    String? pincode,
    String? occupation,
    String? incomeLevel,
    int? familySize,
    Map<String, dynamic>? customFields,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      referralType: referralType ?? this.referralType,
      verified: verified ?? this.verified,
      email: email ?? this.email,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      occupation: occupation ?? this.occupation,
      incomeLevel: incomeLevel ?? this.incomeLevel,
      familySize: familySize ?? this.familySize,
      customFields: customFields ?? this.customFields,
    );
  }
}
