class SarfaesiDetailsResponse {
  final bool success;
  final SarfaesiDetailsData? data;
  final String message;

  SarfaesiDetailsResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory SarfaesiDetailsResponse.fromJson(
      Map<String, dynamic> json,
      ) =>
      SarfaesiDetailsResponse(
        success: json["success"] ?? false,
        data: json["data"] != null
            ? SarfaesiDetailsData.fromJson(json["data"])
            : null,
        message: json["message"] ?? "",
      );
}

class SarfaesiDetailsData {
  final int id;
  final String lan;
  final String customerName;
  final String propertyAddress;
  final String residentialAddress;
  final String mobile;
  final String alternateMobile;
  final double pos;
  final double tos;
  final int dpd;
  final String branchCode;
  final String branchName;
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
  final double estimatedPropertyValue;
  final String customerIntentCapability;
  final String nonPossessionReason;
  final String responseStatus;
  final String? createdBy;
  final DateTime? createdDt;
  final String? updatedBy;
  final DateTime? updatedDt;

  final List<SarfaesiFile> files;

  SarfaesiDetailsData({
    required this.id,
    required this.lan,
    required this.customerName,
    required this.propertyAddress,
    required this.residentialAddress,
    required this.mobile,
    required this.alternateMobile,
    required this.pos,
    required this.tos,
    required this.dpd,
    required this.branchCode,
    required this.branchName,
    required this.region,
    required this.zone,
    required this.megaZone,
    required this.isPossessionTaken,
    this.possessionDate,
    required this.is134HandService,
    required this.customerProfile,
    required this.propertyOccupiedBy,
    required this.propertyType,
    required this.propertyCondition,
    required this.estimatedPropertyValue,
    required this.customerIntentCapability,
    required this.nonPossessionReason,
    required this.responseStatus,
    this.createdBy,
    this.createdDt,
    this.updatedBy,
    this.updatedDt,
    required this.files,
  });

  factory SarfaesiDetailsData.fromJson(
      Map<String, dynamic> json,
      ) =>
      SarfaesiDetailsData(
        id: json["id"] ?? 0,
        lan: json["lan"] ?? "",
        customerName: json["customerName"] ?? "",
        propertyAddress: json["propertyAddress"] ?? "",
        residentialAddress: json["residentialAddress"] ?? "",
        mobile: json["mobile"] ?? "",
        alternateMobile: json["alternateMobile"] ?? "",
        pos: (json["pos"] as num?)?.toDouble() ?? 0.0,
        tos: (json["tos"] as num?)?.toDouble() ?? 0.0,
        dpd: json["dpd"] ?? 0,
        branchCode: json["branchCode"] ?? "",
        branchName: json["branchName"] ?? "",
        region: json["region"] ?? "",
        zone: json["zone"] ?? "",
        megaZone: json["megaZone"] ?? "",
        isPossessionTaken:
        json["isPossessionTaken"] ?? false,
        possessionDate: json["possessionDate"] != null
            ? DateTime.parse(json["possessionDate"])
            : null,
        is134HandService:
        json["is134HandService"] ?? false,
        customerProfile:
        json["customerProfile"] ?? "",
        propertyOccupiedBy:
        json["propertyOccupiedBy"] ?? "",
        propertyType: json["propertyType"] ?? "",
        propertyCondition:
        json["propertyCondition"] ?? "",
        estimatedPropertyValue:
        (json["estimatedPropertyValue"] as num?)
            ?.toDouble() ??
            0.0,
        customerIntentCapability:
        json["customerIntentCapability"] ?? "",
        nonPossessionReason:
        json["nonPossessionReason"] ?? "",
        responseStatus:
        json["responseStatus"] ?? "",
        createdBy: json["createdBy"],
        createdDt: json["createdDt"] != null
            ? DateTime.parse(json["createdDt"])
            : null,
        updatedBy: json["updatedBy"],
        updatedDt: json["updatedDt"] != null
            ? DateTime.parse(json["updatedDt"])
            : null,
        files: json["files"] != null
            ? List<SarfaesiFile>.from(
          json["files"].map(
                (x) => SarfaesiFile.fromJson(x),
          ),
        )
            : [],
      );
}

class SarfaesiFile {
  final int id;
  final int reqId;
  final String fileType;
  final String fileName;
  final String? uploadedBy;
  final DateTime? uploadedDt;

  SarfaesiFile({
    required this.id,
    required this.reqId,
    required this.fileType,
    required this.fileName,
    this.uploadedBy,
    this.uploadedDt,
  });

  factory SarfaesiFile.fromJson(
      Map<String, dynamic> json,
      ) =>
      SarfaesiFile(
        id: json["id"] ?? 0,
        reqId: json["reqId"] ?? 0,
        fileType: json["fileType"] ?? "",
        fileName: json["fileName"] ?? "",
        uploadedBy: json["uploadedBy"],
        uploadedDt: json["uploadedDt"] != null
            ? DateTime.parse(json["uploadedDt"])
            : null,
      );
}