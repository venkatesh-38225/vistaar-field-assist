

import 'dart:convert';

LoginResponse loginResponseFromMap(String str) => LoginResponse.fromMap(json.decode(str));

String loginResponseToMap(LoginResponse data) => json.encode(data.toMap());

class LoginResponse {
  final bool? success;
  final dynamic error;
  final String? otp;

  LoginResponse({
    this.success,
    this.error,
    this.otp,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
    success: json["success"],
    error: json["error"],
    otp: json["otp"],
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "error": error,
    "otp": otp,
  };
}
