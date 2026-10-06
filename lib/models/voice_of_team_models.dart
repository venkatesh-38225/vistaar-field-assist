import 'package:intl/intl.dart';

bool? _parseBool(dynamic val) {
  if (val == null) return null;
  if (val is bool) return val;
  if (val is num) return val != 0;
  if (val is String) {
    final lower = val.trim().toLowerCase();
    if (lower == 'true' || lower == 'yes' || lower == '1' || lower == 'y') {
      return true;
    }
    if (lower == 'false' || lower == 'no' || lower == '0' || lower == 'n') {
      return false;
    }
  }
  return null;
}

double? _parseDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) {
    final cleaned = val.replaceAll('₹', '').replaceAll(',', '').trim();
    return double.tryParse(cleaned);
  }
  return null;
}

int? _parseInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) {
    final cleaned = val.replaceAll(RegExp(r'[^0-9\-]'), '').trim();
    return int.tryParse(cleaned);
  }
  return null;
}

class VotLanResponse {
  final bool success;
  final List<VotLanItem> data;
  final String? message;

  VotLanResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory VotLanResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<VotLanItem> list = [];
    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((item) => VotLanItem.fromJson(item))
          .toList();
    }
    return VotLanResponse(
      success: _parseBool(json['success']) ?? false,
      data: list,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class VotLanItem {
  final int id;
  final String lan;
  final String custName;
  final String empId;

  VotLanItem({
    required this.id,
    required this.lan,
    required this.custName,
    required this.empId,
  });

  factory VotLanItem.fromJson(Map<String, dynamic> json) {
    return VotLanItem(
      id: _parseInt(json['id']) ?? 0,
      lan: json['lan']?.toString() ?? '',
      custName: json['custName']?.toString() ?? '',
      empId: json['empId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lan': lan,
      'custName': custName,
      'empId': empId,
    };
  }
}

class VotCaseResponse {
  final bool success;
  final List<VotCaseItem> data;
  final String? message;

  VotCaseResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory VotCaseResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    List<VotCaseItem> list = [];
    if (rawData is List) {
      list = rawData
          .whereType<Map<String, dynamic>>()
          .map((item) => VotCaseItem.fromJson(item))
          .toList();
    }
    return VotCaseResponse(
      success: _parseBool(json['success']) ?? false,
      data: list,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class VotCaseItem {
  final int id;
  final String lan;
  final String? caseType;
  final String custName;
  final String? custAddress;
  final double? disbAmount;
  final DateTime? disbDate;
  final DateTime? maturityDate;
  final double? principalOutstanding;
  final int? dpd;
  final String? branchCode;
  final String? branchName;
  final String? region;
  final String? zone;
  final String? megaZone;
  final String? customerIssue;
  final String? cdsmRemarks;
  final String? propertyCondition;
  final bool? loanRecoverable;
  final String? nonRecoveryReason;
  final bool? zdshVisited;
  final bool? zdshReviewed;
  final String? zdshComments;
  final String? zdshResolutionPlan;
  final String? zdshRemarks;
  final String? zdshDecision;
  final bool? mzdshVisited;
  final bool? mzdshReviewed;
  final String? mzdshRemarks;
  final String? mzdshDecision;
  final String? auditFinding;
  final bool? isSubstantiated;
  final String? actionRecommended;
  final String? auditRemarks;
  final bool? canBeClosed;
  final String status;
  final String? createdBy;
  final DateTime? createdDt;
  final String? updatedBy;
  final DateTime? updatedDt;

  VotCaseItem({
    required this.id,
    required this.lan,
    this.caseType,
    required this.custName,
    this.custAddress,
    this.disbAmount,
    this.disbDate,
    this.maturityDate,
    this.principalOutstanding,
    this.dpd,
    this.branchCode,
    this.branchName,
    this.region,
    this.zone,
    this.megaZone,
    this.customerIssue,
    this.cdsmRemarks,
    this.propertyCondition,
    this.loanRecoverable,
    this.nonRecoveryReason,
    this.zdshVisited,
    this.zdshReviewed,
    this.zdshComments,
    this.zdshResolutionPlan,
    this.zdshRemarks,
    this.zdshDecision,
    this.mzdshVisited,
    this.mzdshReviewed,
    this.mzdshRemarks,
    this.mzdshDecision,
    this.auditFinding,
    this.isSubstantiated,
    this.actionRecommended,
    this.auditRemarks,
    this.canBeClosed,
    required this.status,
    this.createdBy,
    this.createdDt,
    this.updatedBy,
    this.updatedDt,
  });

  factory VotCaseItem.fromJson(Map<String, dynamic> json) {
    return VotCaseItem(
      id: _parseInt(json['id']) ?? 0,
      lan: json['lan']?.toString() ?? '',
      caseType: json['caseType']?.toString(),
      custName: json['custName']?.toString() ?? '',
      custAddress: json['custAddress']?.toString(),
      disbAmount: _parseDouble(json['disbAmount']),
      disbDate: DateTime.tryParse(json['disbDate']?.toString() ?? ''),
      maturityDate: DateTime.tryParse(json['maturityDate']?.toString() ?? ''),
      principalOutstanding: _parseDouble(json['principalOutstanding']),
      dpd: _parseInt(json['dpd']),
      branchCode: json['branchCode']?.toString(),
      branchName: json['branchName']?.toString(),
      region: json['region']?.toString(),
      zone: json['zone']?.toString(),
      megaZone: json['megaZone']?.toString(),
      customerIssue: json['customerIssue']?.toString(),
      cdsmRemarks: json['cdsmRemarks']?.toString(),
      propertyCondition: json['propertyCondition']?.toString(),
      loanRecoverable: _parseBool(json['loanRecoverable']),
      nonRecoveryReason: json['nonRecoveryReason']?.toString(),
      zdshVisited: _parseBool(json['zdshVisited']),
      zdshReviewed: _parseBool(json['zdshReviewed']),
      zdshComments: json['zdshComments']?.toString(),
      zdshResolutionPlan: json['zdshResolutionPlan']?.toString(),
      zdshRemarks: json['zdshRemarks']?.toString(),
      zdshDecision: json['zdshDecision']?.toString(),
      mzdshVisited: _parseBool(json['mzdshVisited']),
      mzdshReviewed: _parseBool(json['mzdshReviewed']),
      mzdshRemarks: json['mzdshRemarks']?.toString(),
      mzdshDecision: json['mzdshDecision']?.toString(),
      auditFinding: json['auditFinding']?.toString(),
      isSubstantiated: _parseBool(json['isSubstantiated']),
      actionRecommended: json['actionRecommended']?.toString(),
      auditRemarks: json['auditRemarks']?.toString(),
      canBeClosed: _parseBool(json['canBeClosed']),
      status: json['status']?.toString() ?? '',
      createdBy: json['createdBy']?.toString(),
      createdDt: DateTime.tryParse(json['createdDt']?.toString() ?? ''),
      updatedBy: json['updatedBy']?.toString(),
      updatedDt: DateTime.tryParse(json['updatedDt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lan': lan,
      'caseType': caseType,
      'custName': custName,
      'custAddress': custAddress,
      'disbAmount': disbAmount,
      'disbDate': disbDate?.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'principalOutstanding': principalOutstanding,
      'dpd': dpd,
      'branchCode': branchCode,
      'branchName': branchName,
      'region': region,
      'zone': zone,
      'megaZone': megaZone,
      'customerIssue': customerIssue,
      'cdsmRemarks': cdsmRemarks,
      'propertyCondition': propertyCondition,
      'loanRecoverable': loanRecoverable,
      'nonRecoveryReason': nonRecoveryReason,
      'zdshVisited': zdshVisited,
      'zdshReviewed': zdshReviewed,
      'zdshComments': zdshComments,
      'zdshResolutionPlan': zdshResolutionPlan,
      'zdshRemarks': zdshRemarks,
      'zdshDecision': zdshDecision,
      'mzdshVisited': mzdshVisited,
      'mzdshReviewed': mzdshReviewed,
      'mzdshRemarks': mzdshRemarks,
      'mzdshDecision': mzdshDecision,
      'auditFinding': auditFinding,
      'isSubstantiated': isSubstantiated,
      'actionRecommended': actionRecommended,
      'auditRemarks': auditRemarks,
      'canBeClosed': canBeClosed,
      'status': status,
      'createdBy': createdBy,
      'createdDt': createdDt?.toIso8601String(),
      'updatedBy': updatedBy,
      'updatedDt': updatedDt?.toIso8601String(),
    };
  }

  String get formattedDisbDate => disbDate == null
      ? 'N/A'
      : DateFormat('dd-MMM-yyyy').format(disbDate!);

  String get formattedMaturityDate => maturityDate == null
      ? 'N/A'
      : DateFormat('dd-MMM-yyyy').format(maturityDate!);

  String get formattedCreatedDt => createdDt == null
      ? 'N/A'
      : DateFormat('dd-MMM-yyyy HH:mm').format(createdDt!);

  String get formattedUpdatedDt => updatedDt == null
      ? 'N/A'
      : DateFormat('dd-MMM-yyyy HH:mm').format(updatedDt!);
}

class VotCaseDetailsResponse {
  final bool success;
  final VotCaseDetailsData? data;
  final String? message;

  VotCaseDetailsResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory VotCaseDetailsResponse.fromJson(Map<String, dynamic> json) {
    var rawData = json['data'];
    VotCaseDetailsData? dataObj;
    if (rawData is Map<String, dynamic>) {
      dataObj = VotCaseDetailsData.fromJson(rawData);
    }
    return VotCaseDetailsResponse(
      success: _parseBool(json['success']) ?? false,
      data: dataObj,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class VotCaseDetailsData {
  final VotCaseItem? caseItem;
  final List<VotLogItem> logs;
  final List<VotUploadItem> uploads;

  VotCaseDetailsData({
    this.caseItem,
    required this.logs,
    required this.uploads,
  });

  factory VotCaseDetailsData.fromJson(Map<String, dynamic> json) {
    var caseRaw = json['case'];
    VotCaseItem? parsedCase;
    if (caseRaw is Map<String, dynamic>) {
      parsedCase = VotCaseItem.fromJson(caseRaw);
    }

    var logsRaw = json['logs'];
    List<VotLogItem> logsList = [];
    if (logsRaw is List) {
      logsList = logsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => VotLogItem.fromJson(item))
          .toList();
    }

    var uploadsRaw = json['uploads'];
    List<VotUploadItem> uploadsList = [];
    if (uploadsRaw is List) {
      uploadsList = uploadsRaw
          .whereType<Map<String, dynamic>>()
          .map((item) => VotUploadItem.fromJson(item))
          .toList();
    }

    return VotCaseDetailsData(
      caseItem: parsedCase,
      logs: logsList,
      uploads: uploadsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'case': caseItem?.toJson(),
      'logs': logs.map((e) => e.toJson()).toList(),
      'uploads': uploads.map((e) => e.toJson()).toList(),
    };
  }
}

class VotLogItem {
  final int id;
  final int caseId;
  final String? action;
  final String? status;
  final String? remarks;
  final String? createdBy;
  final DateTime? createdDt;

  VotLogItem({
    required this.id,
    required this.caseId,
    this.action,
    this.status,
    this.remarks,
    this.createdBy,
    this.createdDt,
  });

  factory VotLogItem.fromJson(Map<String, dynamic> json) {
    return VotLogItem(
      id: _parseInt(json['id']) ?? 0,
      caseId: _parseInt(json['caseId']) ?? 0,
      action: json['action']?.toString(),
      status: json['status']?.toString(),
      remarks: json['remarks']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdDt: DateTime.tryParse(json['createdDt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'action': action,
      'status': status,
      'remarks': remarks,
      'createdBy': createdBy,
      'createdDt': createdDt?.toIso8601String(),
    };
  }

  String get formattedCreatedDt => createdDt == null
      ? 'N/A'
      : DateFormat('dd-MMM-yyyy HH:mm').format(createdDt!);
}

class VotUploadItem {
  final int id;
  final int caseId;
  final String? fileType;
  final String? filePath;
  final String? createdBy;
  final DateTime? createdDate;

  VotUploadItem({
    required this.id,
    required this.caseId,
    this.fileType,
    this.filePath,
    this.createdBy,
    this.createdDate,
  });

  factory VotUploadItem.fromJson(Map<String, dynamic> json) {
    return VotUploadItem(
      id: _parseInt(json['id']) ?? 0,
      caseId: _parseInt(json['caseId']) ?? 0,
      fileType: json['fileType']?.toString(),
      filePath: json['filePath']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdDate: DateTime.tryParse(json['createdDate']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caseId': caseId,
      'fileType': fileType,
      'filePath': filePath,
      'createdBy': createdBy,
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  String get formattedCreatedDate => createdDate == null
      ? 'N/A'
      : DateFormat('dd-MMM-yyyy HH:mm').format(createdDate!);
}
