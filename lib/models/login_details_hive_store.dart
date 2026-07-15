// To parse this JSON data, do
//
//     final loginDetails = loginDetailsFromMap(jsonString);

import 'package:hive/hive.dart';
import 'dart:convert';

part 'login_details_hive_store.g.dart';

LoginDetails loginDetailsFromMap(String str) => LoginDetails.fromMap(json.decode(str));

String loginDetailsToMap(LoginDetails data) => json.encode(data.toMap());

@HiveType(typeId: 1)
class LoginDetails {
  @HiveField(1)
  final String? employeeId;

  LoginDetails({
    this.employeeId,
  });

  factory LoginDetails.fromMap(Map<String, dynamic> json) => LoginDetails(
    employeeId: json["employeeId"],
  );

  Map<String, dynamic> toMap() => {
    "employeeId": employeeId,
  };
}
