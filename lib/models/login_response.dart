import 'dart:convert';

LoginResponse loginResponseFromMap(String str) =>
    LoginResponse.fromMap(json.decode(str));

String loginResponseToMap(LoginResponse data) => json.encode(data.toMap());

class LoginResponse {
  final bool? success;
  final dynamic error;
  final String? message;
  final bool twoFactorEnabled;

  LoginResponse({
    this.success,
    this.error,
    this.message,
    this.twoFactorEnabled = false,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> json) {
    final data = json['data'];
    return LoginResponse(
      success: json['success'] == true,
      error: json['error'],
      message: json['message']?.toString(),
      twoFactorEnabled:
          data is Map<String, dynamic> && data['twoFactorEnabled'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'success': success,
        'error': error,
        'message': message,
        'data': {'twoFactorEnabled': twoFactorEnabled},
      };
}
