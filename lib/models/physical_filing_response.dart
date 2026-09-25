class PhysicalFilingListResponse {
  const PhysicalFilingListResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  final bool success;
  final List<PhysicalFilingCase> data;
  final String message;

  factory PhysicalFilingListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return PhysicalFilingListResponse(
      success: json['success'] == true,
      data: rawData is List
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(PhysicalFilingCase.fromJson)
              .toList()
          : [],
      message: json['message']?.toString() ?? '',
    );
  }
}

class PhysicalFilingDetailsResponse {
  const PhysicalFilingDetailsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  final bool success;
  final PhysicalFilingCase? data;
  final String message;

  factory PhysicalFilingDetailsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return PhysicalFilingDetailsResponse(
      success: json['success'] == true,
      data: rawData is Map<String, dynamic>
          ? PhysicalFilingCase.fromJson(rawData)
          : null,
      message: json['message']?.toString() ?? '',
    );
  }
}

class PhysicalFilingCase {
  const PhysicalFilingCase({
    required this.id,
    required this.caseId,
    required this.lan,
    this.branchCode,
    this.branchName,
    this.region,
    this.zone,
    this.megaZone,
    required this.status,
    required this.dashboardStatus,
    required this.dispatchDate,
    required this.podNumber,
    required this.courierName,
    required this.documentTransmissionType,
    this.emailDate,
    this.emailSubject,
    required this.advocateId,
    required this.advocateName,
    required this.advocateAssignmentDate,
    required this.filingType,
    required this.courtName,
    required this.eFilingDate,
    required this.eFilingCaseNumber,
    required this.physicalFilingDate,
    required this.physicalFilingCaseNumber,
    this.withdrawalReason,
    this.withdrawalRemarks,
    this.withdrawalStatus,
    this.withdrawalRequestedBy,
    this.withdrawalRequestedDt,
    this.withdrawalReviewedBy,
    this.withdrawalReviewedDt,
    this.withdrawalReviewRemarks,
    this.isDirectWithdrawal,
    this.documentReturnStatus,
    this.documentReturnPODNumber,
    this.documentReturnDispatchDate,
    this.documentReturnCourierName,
    this.documentReturnRemarks,
    this.documentReturnRequestedBy,
    this.documentReturnRequestedDt,
    this.documentReturnCompletedBy,
    this.documentReturnCompletedDt,
    this.requiresPhysicalDocuments,
    this.requiresAdditionalDocuments,
    required this.createdBy,
    required this.createdDt,
    required this.updatedBy,
    required this.updatedDt,
    required this.checklist,
    required this.logs,
  });

  final int id;
  final int caseId;
  final String lan;
  final String? branchCode;
  final String? branchName;
  final String? region;
  final String? zone;
  final String? megaZone;
  final String status;
  final String dashboardStatus;
  final DateTime? dispatchDate;
  final String podNumber;
  final String courierName;
  final String? documentTransmissionType;
  final DateTime? emailDate;
  final String? emailSubject;
  final int advocateId;
  final String advocateName;
  final DateTime? advocateAssignmentDate;
  final String filingType;
  final String courtName;
  final DateTime? eFilingDate;
  final String eFilingCaseNumber;
  final DateTime? physicalFilingDate;
  final String physicalFilingCaseNumber;
  final String? withdrawalReason;
  final String? withdrawalRemarks;
  final String? withdrawalStatus;
  final String? withdrawalRequestedBy;
  final DateTime? withdrawalRequestedDt;
  final String? withdrawalReviewedBy;
  final DateTime? withdrawalReviewedDt;
  final String? withdrawalReviewRemarks;
  final bool? isDirectWithdrawal;
  final String? documentReturnStatus;
  final String? documentReturnPODNumber;
  final DateTime? documentReturnDispatchDate;
  final String? documentReturnCourierName;
  final String? documentReturnRemarks;
  final String? documentReturnRequestedBy;
  final DateTime? documentReturnRequestedDt;
  final String? documentReturnCompletedBy;
  final DateTime? documentReturnCompletedDt;
  final bool? requiresPhysicalDocuments;
  final bool? requiresAdditionalDocuments;
  final String createdBy;
  final DateTime? createdDt;
  final String updatedBy;
  final DateTime? updatedDt;
  final List<PhysicalFilingChecklistItem> checklist;
  final List<PhysicalFilingLog> logs;

  bool get hasWithdrawalDetails =>
      (withdrawalStatus != null && withdrawalStatus!.trim().isNotEmpty) ||
      (withdrawalReason != null && withdrawalReason!.trim().isNotEmpty) ||
      (withdrawalRemarks != null && withdrawalRemarks!.trim().isNotEmpty) ||
      (withdrawalRequestedBy != null &&
          withdrawalRequestedBy!.trim().isNotEmpty) ||
      (withdrawalReviewedBy != null &&
          withdrawalReviewedBy!.trim().isNotEmpty);

  bool get hasDocumentReturnDetails =>
      (documentReturnStatus != null &&
          documentReturnStatus!.trim().isNotEmpty) ||
      (documentReturnPODNumber != null &&
          documentReturnPODNumber!.trim().isNotEmpty) ||
      (documentReturnCourierName != null &&
          documentReturnCourierName!.trim().isNotEmpty) ||
      (documentReturnRemarks != null &&
          documentReturnRemarks!.trim().isNotEmpty) ||
      (documentReturnRequestedBy != null &&
          documentReturnRequestedBy!.trim().isNotEmpty) ||
      (documentReturnRequestedDt != null) ||
      (documentReturnCompletedBy != null &&
          documentReturnCompletedBy!.trim().isNotEmpty) ||
      (documentReturnCompletedDt != null);

  bool get hasAdvocateDetails =>
      advocateId > 0 ||
      advocateName.trim().isNotEmpty ||
      advocateAssignmentDate != null;

  bool get hasFilingDetails =>
      filingType.trim().isNotEmpty ||
      courtName.trim().isNotEmpty ||
      eFilingDate != null ||
      eFilingCaseNumber.trim().isNotEmpty ||
      physicalFilingDate != null ||
      physicalFilingCaseNumber.trim().isNotEmpty;

  factory PhysicalFilingCase.fromJson(Map<String, dynamic> json) {
    final rawChecklist = json['checklist'];
    final rawLogs = json['logs'];
    final id =
        (json['id'] as num?)?.toInt() ?? (json['caseId'] as num?)?.toInt() ?? 0;
    return PhysicalFilingCase(
      id: id,
      caseId: (json['caseId'] as num?)?.toInt() ?? id,
      lan: json['lan']?.toString() ?? '',
      branchCode: json['branchCode']?.toString(),
      branchName: json['branchName']?.toString(),
      region: json['region']?.toString(),
      zone: json['zone']?.toString(),
      megaZone: json['megaZone']?.toString(),
      status: json['status']?.toString() ?? '',
      dashboardStatus: json['dashboardStatus']?.toString() ?? '',
      dispatchDate: DateTime.tryParse(json['dispatchDate']?.toString() ?? ''),
      podNumber: json['podNumber']?.toString() ?? '',
      courierName: json['courierName']?.toString() ?? '',
      documentTransmissionType: json['documentTransmissionType']?.toString(),
      emailDate: DateTime.tryParse(json['emailDate']?.toString() ?? ''),
      emailSubject: json['emailSubject']?.toString(),
      advocateId: (json['advocateId'] as num?)?.toInt() ?? 0,
      advocateName: json['advocateName']?.toString() ?? '',
      advocateAssignmentDate: DateTime.tryParse(
        json['advocateAssignmentDate']?.toString() ?? '',
      ),
      filingType: json['filingType']?.toString() ?? '',
      courtName: json['courtName']?.toString() ?? '',
      eFilingDate: DateTime.tryParse(json['eFilingDate']?.toString() ?? ''),
      eFilingCaseNumber: json['eFilingCaseNumber']?.toString() ?? '',
      physicalFilingDate: DateTime.tryParse(
        json['physicalFilingDate']?.toString() ?? '',
      ),
      physicalFilingCaseNumber:
          json['physicalFilingCaseNumber']?.toString() ?? '',
      withdrawalReason: json['withdrawalReason']?.toString(),
      withdrawalRemarks: json['withdrawalRemarks']?.toString(),
      withdrawalStatus: json['withdrawalStatus']?.toString(),
      withdrawalRequestedBy: json['withdrawalRequestedBy']?.toString(),
      withdrawalRequestedDt: DateTime.tryParse(
        json['withdrawalRequestedDt']?.toString() ?? '',
      ),
      withdrawalReviewedBy: json['withdrawalReviewedBy']?.toString(),
      withdrawalReviewedDt: DateTime.tryParse(
        json['withdrawalReviewedDt']?.toString() ?? '',
      ),
      withdrawalReviewRemarks: json['withdrawalReviewRemarks']?.toString(),
      isDirectWithdrawal: json['isDirectWithdrawal'] as bool?,
      documentReturnStatus: json['documentReturnStatus']?.toString(),
      documentReturnPODNumber: json['documentReturnPODNumber']?.toString(),
      documentReturnDispatchDate: DateTime.tryParse(
        json['documentReturnDispatchDate']?.toString() ?? '',
      ),
      documentReturnCourierName: json['documentReturnCourierName']?.toString(),
      documentReturnRemarks: json['documentReturnRemarks']?.toString(),
      documentReturnRequestedBy: json['documentReturnRequestedBy']?.toString(),
      documentReturnRequestedDt: DateTime.tryParse(
        json['documentReturnRequestedDt']?.toString() ?? '',
      ),
      documentReturnCompletedBy:
          json['documentReturnCompletedBy']?.toString(),
      documentReturnCompletedDt: DateTime.tryParse(
        json['documentReturnCompletedDt']?.toString() ?? '',
      ),
      requiresPhysicalDocuments: json['requiresPhysicalDocuments'] as bool?,
      requiresAdditionalDocuments:
          json['requiresAdditionalDocuments'] as bool?,
      createdBy: json['createdBy']?.toString() ?? '',
      createdDt: DateTime.tryParse(json['createdDt']?.toString() ?? ''),
      updatedBy: json['updatedBy']?.toString() ?? '',
      updatedDt: DateTime.tryParse(json['updatedDt']?.toString() ?? ''),
      checklist: rawChecklist is List
          ? rawChecklist
              .whereType<Map<String, dynamic>>()
              .map(PhysicalFilingChecklistItem.fromJson)
              .toList()
          : [],
      logs: rawLogs is List
          ? rawLogs
              .whereType<Map<String, dynamic>>()
              .map(PhysicalFilingLog.fromJson)
              .toList()
          : [],
    );
  }
}

class PhysicalFilingLog {
  const PhysicalFilingLog({
    required this.id,
    required this.caseId,
    required this.action,
    required this.stage,
    required this.remarks,
    required this.createdBy,
    required this.createdDt,
  });

  final int id;
  final int caseId;
  final String action;
  final String stage;
  final String? remarks;
  final String createdBy;
  final DateTime? createdDt;

  factory PhysicalFilingLog.fromJson(Map<String, dynamic> json) {
    return PhysicalFilingLog(
      id: (json['id'] as num?)?.toInt() ?? 0,
      caseId: (json['caseId'] as num?)?.toInt() ?? 0,
      action: json['action']?.toString() ?? '',
      stage: json['stage']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      createdBy: json['createdBy']?.toString() ?? '',
      createdDt: DateTime.tryParse(json['createdDt']?.toString() ?? ''),
    );
  }
}

class PhysicalFilingChecklistItem {
  const PhysicalFilingChecklistItem({
    required this.id,
    required this.caseId,
    required this.documentId,
    required this.documentName,
    required this.legalAvailable,
    required this.fieldReceived,
    required this.legalComments,
    required this.fieldComments,
    this.identificationNumber,
    required this.hasDiscrepancy,
    this.isMandatory = false,
  });

  final int id;
  final int caseId;
  final int documentId;
  final String documentName;
  final bool legalAvailable;
  final bool? fieldReceived;
  final String? legalComments;
  final String? fieldComments;
  final String? identificationNumber;
  final bool hasDiscrepancy;
  final bool isMandatory;

  factory PhysicalFilingChecklistItem.fromJson(Map<String, dynamic> json) {
    return PhysicalFilingChecklistItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      caseId: (json['caseId'] as num?)?.toInt() ?? 0,
      documentId: (json['documentId'] as num?)?.toInt() ?? 0,
      documentName: json['documentName']?.toString() ?? '',
      legalAvailable: json['legalAvailable'] == true,
      fieldReceived: json['fieldReceived'] as bool?,
      legalComments: json['legalComments']?.toString(),
      fieldComments: json['fieldComments']?.toString(),
      identificationNumber: json['identificationNumber']?.toString(),
      hasDiscrepancy: json['hasDiscrepancy'] == true,
      isMandatory: json['isMandatory'] == true,
    );
  }
}
