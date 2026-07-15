import 'dart:convert';
import 'package:re_kyc_mobile_app/models/legal_billing_res.dart';
import 'package:re_kyc_mobile_app/models/legal_masters.dart';

class LegalBillingDetailsResponse {
  final bool success;
  final LegalBillingDetailsData? data;
  final String message;

  LegalBillingDetailsResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory LegalBillingDetailsResponse.fromJson(Map<String, dynamic> json) =>
      LegalBillingDetailsResponse(
        success: json["success"] ?? false,
        data: json["data"] != null
            ? LegalBillingDetailsData.fromJson(json["data"])
            : null,
        message: json["message"] ?? "",
      );
}

class LegalBillingDetailsData {
  final Transaction transaction;
  final Advocate? advocate;
  final LegalCategory? legalCategory;
  final List<BillingLog> logs;

  LegalBillingDetailsData({
    required this.transaction,
    this.advocate,
    this.legalCategory,
    required this.logs,
  });

  factory LegalBillingDetailsData.fromJson(Map<String, dynamic> json) =>
      LegalBillingDetailsData(
        transaction: Transaction.fromJson(json["transaction"]),
        advocate: json["advocate"] != null
            ? Advocate.fromJson(json["advocate"])
            : null,
        legalCategory: json["legalCategory"] != null
            ? LegalCategory.fromJson(json["legalCategory"])
            : null,
        logs: json["logs"] != null
            ? List<BillingLog>.from(json["logs"].map((x) => BillingLog.fromJson(x)))
            : [],
      );
}

class Transaction {
  final int id;
  final String lan;
  final String branchId;
  final String? branchName;
  final String? region;
  final String? zone;
  final String? megaZone;
  final String custId;
  final String customerName;
  final double pos;
  final double totalOutstanding;
  final int dpd;
  final int advocateId;
  final int legalCategoryId;
  final double paymentAmount;
  final String? paymentType;
  final String? bankName;
  final String? bankAcNo;
  final String? ifsc;
  final String? cancelledCheque;
  final String? cancelledChequeFilePath;
  final String? invoiceFilePath;
  final String? remarks;
  final String status;
  final String? pendingRole;
  final String? pendingUser;
  final String? paymentStatus;
  final String? paymentRemarks;
  final String? utr;
  final DateTime? createdDate;
  final String? createdBy;
  final bool isApproved;

  Transaction({
    required this.id,
    required this.lan,
    required this.branchId,
    this.branchName,
    this.region,
    this.zone,
    this.megaZone,
    required this.custId,
    required this.customerName,
    required this.pos,
    required this.totalOutstanding,
    required this.dpd,
    required this.advocateId,
    required this.legalCategoryId,
    required this.paymentAmount,
    this.paymentType,
    this.bankName,
    this.bankAcNo,
    this.ifsc,
    this.cancelledCheque,
    this.cancelledChequeFilePath,
    this.invoiceFilePath,
    this.remarks,
    required this.status,
    this.pendingRole,
    this.pendingUser,
    this.paymentStatus,
    this.paymentRemarks,
    this.utr,
    this.createdDate,
    this.createdBy,
    required this.isApproved,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"] ?? 0,
        lan: json["lan"] ?? "",
        branchId: json["branchId"] ?? "",
        branchName: json["branchName"],
        region: json["region"],
        zone: json["zone"],
        megaZone: json["megaZone"],
        custId: json["custId"] ?? "",
        customerName: json["customerName"] ?? "",
        pos: (json["pos"] as num?)?.toDouble() ?? 0.0,
        totalOutstanding: (json["totalOutstanding"] as num?)?.toDouble() ?? 0.0,
        dpd: json["dpd"] ?? 0,
        advocateId: json["advocateId"] ?? 0,
        legalCategoryId: json["legalCategoryId"] ?? 0,
        paymentAmount: (json["paymentAmount"] as num?)?.toDouble() ?? 0.0,
        paymentType: json["paymentType"],
        bankName: json["bankName"],
        bankAcNo: json["bankAcNo"],
        ifsc: json["ifsc"],
        cancelledCheque: json["cancelledCheque"],
        cancelledChequeFilePath: json["cancelledChequeFilePath"],
        invoiceFilePath: json["invoiceFilePath"],
        remarks: json["remarks"],
        status: json["status"] ?? "",
        pendingRole: json["pendingRole"],
        pendingUser: json["pendingUser"],
        paymentStatus: json["paymentStatus"],
        paymentRemarks: json["paymentRemarks"],
        utr: json["utr"],
        createdDate: json["createdDate"] != null
            ? DateTime.parse(json["createdDate"])
            : null,
        createdBy: json["createdBy"],
        isApproved: json["isApproved"] ?? false,
      );
}

class BillingLog {
  final int id;
  final int reqId;
  final String? status;
  final String? remarks;
  final String? updatedBy;
  final DateTime? updatedDate;

  BillingLog({
    required this.id,
    required this.reqId,
    this.status,
    this.remarks,
    this.updatedBy,
    this.updatedDate,
  });

  factory BillingLog.fromJson(Map<String, dynamic> json) => BillingLog(
        id: json["id"] ?? 0,
        reqId: json["reqId"] ?? 0,
        status: json["status"],
        remarks: json["remarks"],
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] != null
            ? DateTime.parse(json["updatedDate"])
            : null,
      );
}
