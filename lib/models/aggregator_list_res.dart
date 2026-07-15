// To parse this JSON data, do
//
//     final aggregatorListRes = aggregatorListResFromMap(jsonString);

import 'dart:convert';

AggregatorListRes aggregatorListResFromMap(String str) => AggregatorListRes.fromMap(json.decode(str));

String aggregatorListResToMap(AggregatorListRes data) => json.encode(data.toMap());

class AggregatorListRes {
  final bool? success;
  final dynamic error;
  final List<Datum>? data;

  AggregatorListRes({
    this.success,
    this.error,
    this.data,
  });

  factory AggregatorListRes.fromMap(Map<String, dynamic> json) => AggregatorListRes(
    success: json["success"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "success": success,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
  };
}

class Datum {
  final int? id;
  final String? branchCode;
  final String? aggregatorName;
  final String? mobile;
  final String? email;
  final String? profile;
  final String? officeAddress;
  final String? residenceAddress;
  final String? lat;
  final String? lng;
  final String? historicRemarks;
  final String? remarks;
  final String? createdBy;
  final DateTime? createdDt;
  final String? updatedBy;
  final DateTime? updatedDt;

  Datum({
    this.id,
    this.branchCode,
    this.aggregatorName,
    this.mobile,
    this.email,
    this.profile,
    this.officeAddress,
    this.residenceAddress,
    this.lat,
    this.lng,
    this.historicRemarks,
    this.remarks,
    this.createdBy,
    this.createdDt,
    this.updatedBy,
    this.updatedDt,
  });

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
    id: json["id"],
    branchCode: json["branchCode"],
    aggregatorName: json["aggregatorName"],
    mobile: json["mobile"],
    email: json["email"],
    profile: json["profile"],
    officeAddress: json["officeAddress"],
    residenceAddress: json["residenceAddress"],
    lat: json["lat"],
    lng: json["lng"],
    historicRemarks: json["historicRemarks"],
    remarks: json["remarks"],
    createdBy: json["createdBy"],
    createdDt: json["createdDt"] == null ? null : DateTime.parse(json["createdDt"]),
    updatedBy: json["updatedBy"],
    updatedDt: json["updatedDt"] == null ? null : DateTime.parse(json["updatedDt"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "branchCode": branchCode,
    "aggregatorName": aggregatorName,
    "mobile": mobile,
    "email": email,
    "profile": profile,
    "officeAddress": officeAddress,
    "residenceAddress": residenceAddress,
    "lat": lat,
    "lng": lng,
    "historicRemarks": historicRemarks,
    "remarks": remarks,
    "createdBy": createdBy,
    "createdDt": createdDt?.toIso8601String(),
    "updatedBy": updatedBy,
    "updatedDt": updatedDt?.toIso8601String(),
  };
}
