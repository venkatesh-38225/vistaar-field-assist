import 'dart:convert';

class SarfaesiResponse {
  final bool success;
  final List<SarfaesiData> data;
  final String message;

  SarfaesiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SarfaesiResponse.fromJson(Map<String, dynamic> json) => SarfaesiResponse(
    success: json["success"] ?? false,
    data: json["data"] != null
        ? List<SarfaesiData>.from(json["data"].map((x) => SarfaesiData.fromJson(x)))
        : [],
    message: json["message"] ?? "",
  );
}

  class SarfaesiData {
    final int id;
    final String lan;
    final String branchCode;
    final String? branchName;
    final String customerName;
    final double pos;
    final double tos;
    final String mobile;
    final String alternateMobile;
    final String region;
    final String zone;
    final String megaZone;
    final bool isPossessionTaken;
    final DateTime? possessionDate;
    final bool is134HandService;
    final String customerProfile;
    final String propertyOccupiedBy;
    final String propertyType;
    final String propertyCondition;
    final double paymentAmount;
    final double estimatedPropertyValue;
    final double totalOutstanding;
    final int dpd;
    final String customerIntentCapability;
    final String nonPossessionReason;
    final String status;
    final String? createdBy;
    final String? updatedBy;

    // final String? pendingRole;
    // final String? pendingUser;
    final DateTime? createdDt;
    final DateTime? updatedDt;

    SarfaesiData({
      required this.id,
      required this.lan,
      required this.branchCode,
      this.branchName,
      required this.customerName,
      required this.pos,
      required this.tos,
      required this.mobile,
      required this.alternateMobile,
      required this.region,
      required this.zone,
      required this.megaZone,
      required this.isPossessionTaken,
      required this.is134HandService,
      required this.customerProfile,
      required this.propertyOccupiedBy,
      required this.propertyType,
      required this.propertyCondition,
      required this.paymentAmount,
      required this.estimatedPropertyValue,
      required this.totalOutstanding,
      required this.dpd,
      required this.customerIntentCapability,
      required this.nonPossessionReason,
      required this.status,
      this.possessionDate,
      this.createdBy,
      this.updatedBy,
      this.updatedDt,
      this.createdDt,

    });

    factory SarfaesiData.fromJson(Map<String, dynamic> json) =>
        SarfaesiData(
          id: json["id"] ?? 0,
          lan: json["lan"] ?? "",
          branchCode: json["branchCode"] ?? "",
          branchName: json["branchName"],
          customerName: json["customerName"] ?? "",

          pos: (json["pos"] as num?)?.toDouble() ?? 0.0,
          tos: (json["tos"] as num?)?.toDouble() ?? 0.0,

          mobile: json["mobile"] ?? "",
          alternateMobile: json["alternateMobile"] ?? "",

          region: json["region"] ?? "",
          zone: json["zone"] ?? "",
          megaZone: json["megaZone"] ?? "",

          isPossessionTaken: json["isPossessionTaken"] ?? false,

          is134HandService: json["is134HandService"] ?? false,

          customerProfile: json["customerProfile"] ?? "",
          propertyOccupiedBy: json["propertyOccupiedBy"] ?? "",
          propertyType: json["propertyType"] ?? "",
          propertyCondition: json["propertyCondition"] ?? "",

          paymentAmount:
          (json["paymentAmount"] as num?)?.toDouble() ?? 0.0,

          estimatedPropertyValue:
          (json["estimatedPropertyValue"] as num?)?.toDouble() ?? 0.0,

          totalOutstanding:
          (json["totalOutstanding"] as num?)?.toDouble() ?? 0.0,

          dpd: json["dpd"] ?? 0,

          customerIntentCapability:
          json["customerIntentCapability"] ?? "",

          nonPossessionReason:
          json["nonPossessionReason"] ?? "",

          status: json["status"] ?? "",

          createdBy: json["createdBy"],
          updatedBy: json["updatedBy"],

          createdDt: json["createdDt"] != null
              ? DateTime.parse(json["createdDt"])
              : null,

          possessionDate: json["possessionDate"] != null
              ? DateTime.parse(json["possessionDate"])
              : null,

          updatedDt: json["updatedDt"] != null
              ? DateTime.parse(json["updatedDt"])
              : null,
        );
  }