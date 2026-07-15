import 'dart:convert';

class LegalBillingResponse {
  final bool success;
  final List<LegalBillingData> data;
  final String message;

  LegalBillingResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory LegalBillingResponse.fromJson(Map<String, dynamic> json) => LegalBillingResponse(
        success: json["success"] ?? false,
        data: json["data"] != null
            ? List<LegalBillingData>.from(json["data"].map((x) => LegalBillingData.fromJson(x)))
            : [],
        message: json["message"] ?? "",
      );
}

class LegalBillingData {
  final int id;
  final String lan;
  final String branchId;
  final String? branchName;
  final String customerName;
  final double pos;
  final double paymentAmount;
  final double totalOutstanding;
  final int dpd;
  final String advocateName;
  final String legalCategory;
  final String status;
  final String? pendingRole;
  final String? pendingUser;
  final DateTime? createdDate;

  LegalBillingData({
    required this.id,
    required this.lan,
    required this.branchId,
    this.branchName,
    required this.customerName,
    required this.pos,
    required this.totalOutstanding,
    required this.dpd,
    required this.advocateName,
    required this.legalCategory,
    required this.status,
    this.pendingRole,
    this.pendingUser,
    this.createdDate,
    required this.paymentAmount,
  });

  factory LegalBillingData.fromJson(Map<String, dynamic> json) => LegalBillingData(
        id: json["id"] ?? 0,
        lan: json["lan"] ?? "",
        branchId: json["branchId"] ?? "",
        branchName: json["branchName"],
        customerName: json["customerName"] ?? "",
        pos: (json["pos"] as num?)?.toDouble() ?? 0.0,
        paymentAmount: (json["paymentAmount"] as num?)?.toDouble() ?? 0.0,
        totalOutstanding: (json["totalOutstanding"] as num?)?.toDouble() ?? 0.0,
        dpd: json["dpd"] ?? 0,
        advocateName: json["advocateName"] ?? "",
        legalCategory: json["legalCategory"] ?? "",
        status: json["status"] ?? "",
        pendingRole: json["pendingRole"],
        pendingUser: json["pendingUser"],
        createdDate: json["createdDate"] != null ? DateTime.parse(json["createdDate"]) : null,
      );
}
