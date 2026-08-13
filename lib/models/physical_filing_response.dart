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
    required this.status,
    required this.dashboardStatus,
    required this.dispatchDate,
    required this.podNumber,
    required this.courierName,
    required this.advocateId,
    required this.advocateName,
    required this.advocateAssignmentDate,
    required this.filingType,
    required this.courtName,
    required this.eFilingDate,
    required this.eFilingCaseNumber,
    required this.physicalFilingDate,
    required this.physicalFilingCaseNumber,
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
  final String status;
  final String dashboardStatus;
  final DateTime? dispatchDate;
  final String podNumber;
  final String courierName;
  final int advocateId;
  final String advocateName;
  final DateTime? advocateAssignmentDate;
  final String filingType;
  final String courtName;
  final DateTime? eFilingDate;
  final String eFilingCaseNumber;
  final DateTime? physicalFilingDate;
  final String physicalFilingCaseNumber;
  final String createdBy;
  final DateTime? createdDt;
  final String updatedBy;
  final DateTime? updatedDt;
  final List<PhysicalFilingChecklistItem> checklist;
  final List<PhysicalFilingLog> logs;

  factory PhysicalFilingCase.fromJson(Map<String, dynamic> json) {
    final rawChecklist = json['checklist'];
    final rawLogs = json['logs'];
    final id =
        (json['id'] as num?)?.toInt() ?? (json['caseId'] as num?)?.toInt() ?? 0;
    return PhysicalFilingCase(
      id: id,
      caseId: (json['caseId'] as num?)?.toInt() ?? id,
      lan: json['lan']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dashboardStatus: json['dashboardStatus']?.toString() ?? '',
      dispatchDate: DateTime.tryParse(json['dispatchDate']?.toString() ?? ''),
      podNumber: json['podNumber']?.toString() ?? '',
      courierName: json['courierName']?.toString() ?? '',
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
    required this.hasDiscrepancy,
  });

  final int id;
  final int caseId;
  final int documentId;
  final String documentName;
  final bool legalAvailable;
  final bool? fieldReceived;
  final String? legalComments;
  final String? fieldComments;
  final bool hasDiscrepancy;

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
      hasDiscrepancy: json['hasDiscrepancy'] == true,
    );
  }
}
