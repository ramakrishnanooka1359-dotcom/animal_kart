class CreateUserResponse {
  final int statusCode;
  final String status;
  final String message;

  CreateUserResponse({
    required this.statusCode,
    required this.status,
    required this.message,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      statusCode: json['statuscode'] ?? json['statusCode'] ?? 200,
      status: json['status'] ?? '',
      message: 'You’ve successfully added a referral',
    );
  }
}