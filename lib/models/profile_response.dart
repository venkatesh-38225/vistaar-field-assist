// To parse this JSON data, do
//
//     final profileResponse = profileResponseFromMap(jsonString);

import 'dart:convert';

ProfileResponse profileResponseFromMap(String str) => ProfileResponse.fromMap(json.decode(str));

String profileResponseToMap(ProfileResponse data) => json.encode(data.toMap());

class ProfileResponse {
  final bool? success;
  final dynamic error;
  final Data? data;

  ProfileResponse({
    this.success,
    this.error,
    this.data,
  });

  factory ProfileResponse.fromMap(Map<String, dynamic> json) => ProfileResponse(
    success: json["success"],
    error: json["error"],
    data: json["data"] == null ? null : Data.fromMap(json["data"]),
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "error": error,
    "data": data?.toMap(),
  };
}

class Data {
  final String? employeeId;
  final String? username;
  final String? email;
  final String? mobile;
  final String? jobTitle;
  final String? department;
  final dynamic reportingManager;
  final String? branchCode;
  final String? branchName;
  final String? role;

  Data({
    this.employeeId,
    this.username,
    this.email,
    this.mobile,
    this.jobTitle,
    this.department,
    this.reportingManager,
    this.branchCode,
    this.branchName,
    this.role,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    employeeId: json["employeeID"],
    username: json["username"],
    email: json["email"],
    mobile: json["mobile"],
    jobTitle: json["jobTitle"],
    department: json["department"],
    reportingManager: json["reportingManager"],
    branchCode: json["branchCode"],
    branchName: json["branchName"],
    role: json["role"],
  );

  Map<String, dynamic> toMap() => {
    "employeeID": employeeId,
    "username": username,
    "email": email,
    "mobile": mobile,
    "jobTitle": jobTitle,
    "department": department,
    "reportingManager": reportingManager,
    "branchCode": branchCode,
    "branchName": branchName,
    "role": role,
  };
}
