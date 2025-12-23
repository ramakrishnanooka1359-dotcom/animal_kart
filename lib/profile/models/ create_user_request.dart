class CreateUserRequest {
  final String firstName;
  final String lastName;
  final String mobile;
  final String? referedByMobile;
  final String? referedByName;
  final String role;

  CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.referedByMobile,
    this.referedByName,
    this.role = 'Investor',
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'mobile': mobile,
      if (referedByMobile != null) 'refered_by_mobile': referedByMobile,
      if (referedByName != null) 'refered_by_name': referedByName,
      'role': role,
    };
  }
}