// To parse this JSON data, do
//
//     final eSignPdfModel = eSignPdfModelFromMap(jsonString);

import 'dart:convert';

ESignPdfModel eSignPdfModelFromMap(String str) => ESignPdfModel.fromMap(json.decode(str));

String eSignPdfModelToMap(ESignPdfModel data) => json.encode(data.toMap());

class ESignPdfModel {
  final bool? success;
  final dynamic error;
  final String? data;

  ESignPdfModel({
    this.success,
    this.error,
    this.data,
  });

  factory ESignPdfModel.fromMap(Map<String, dynamic> json) => ESignPdfModel(
    success: json["success"],
    error: json["error"],
    data: json["data"],
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "error": error,
    "data": data,
  };
}
