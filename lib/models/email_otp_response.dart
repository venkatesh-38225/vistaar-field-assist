// To parse this JSON data, do
//
//     final emailOtpRes = emailOtpResFromMap(jsonString);

import 'dart:convert';

EmailOtpRes emailOtpResFromMap(String str) => EmailOtpRes.fromMap(json.decode(str));

String emailOtpResToMap(EmailOtpRes data) => json.encode(data.toMap());

class EmailOtpRes {
  final bool? success;
  final dynamic error;
  final String? otp;

  EmailOtpRes({
    this.success,
    this.error,
    this.otp,
  });

  factory EmailOtpRes.fromMap(Map<String, dynamic> json) => EmailOtpRes(
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
