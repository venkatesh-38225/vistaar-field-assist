// To parse this JSON data, do
//
//     final bankDetailsResp = bankDetailsRespFromMap(jsonString);

import 'dart:convert';

BankDetailsResp bankDetailsRespFromMap(String str) =>
    BankDetailsResp.fromMap(json.decode(str));

String bankDetailsRespToMap(BankDetailsResp data) => json.encode(data.toMap());

class BankDetailsResp {
  final bool? success;
  final dynamic error;
  final Data? data;
  final String? message;

  BankDetailsResp({
    this.success,
    this.error,
    this.data,
    this.message,
  });

  factory BankDetailsResp.fromMap(Map<String, dynamic> json) => BankDetailsResp(
        success: json["success"],
        error: json["error"],
        data: json["data"] == null ? null : Data.fromMap(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "error": error,
        "data": data?.toMap(),
        "message": message,
      };
}

class Data {
  final String? bankCode;
  final String? bankName;
  final String? branchCode;
  final String? branchName;
  final String? micrCode;

  Data({
    this.bankCode,
    this.bankName,
    this.branchCode,
    this.branchName,
    this.micrCode,
  });

  factory Data.fromMap(Map<String, dynamic> json) => Data(
        bankCode: json["bankCode"],
        bankName: json["bankName"],
        branchCode: json["ifscCode"],
        branchName: json["branch"],
        micrCode: json["micr"],
      );

  Map<String, dynamic> toMap() => {
        "bankCode": bankCode,
        "bankName": bankName,
        "branchCode": branchCode,
        "branchName": branchName,
        "micrCode": micrCode,
      };
}
