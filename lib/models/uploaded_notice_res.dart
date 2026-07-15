class UploadedNoticeResponse {
  final bool success;
  final List<UploadedNotice>? data;
  final String message;

  UploadedNoticeResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory UploadedNoticeResponse.fromJson(Map<String, dynamic> json) {
    return UploadedNoticeResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => UploadedNotice.fromJson(i)).toList()
          : null,
      message: json['message'] ?? "",
    );
  }
}

class UploadedNotice {
  final String lan;
  final String noticeType;
  final String subType;
  final String? filePath;
  final String? base64;
  final String? uploadedBy;
  final DateTime? uploadedAt;

  UploadedNotice({
    required this.lan,
    required this.noticeType,
    required this.subType,
    this.filePath,
    this.base64,
    this.uploadedBy,
    this.uploadedAt,
  });

  factory UploadedNotice.fromJson(Map<String, dynamic> json) {
    return UploadedNotice(
      lan: json['lan']?.toString() ?? "",
      noticeType: json['noticeType']?.toString() ?? "",
      subType: json['subType']?.toString() ?? "",
      filePath: json['filePath']?.toString(),
      base64: json['base64']?.toString(),
      uploadedBy: json['uploadedBy']?.toString(),
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.tryParse(json['uploadedAt'].toString()) 
          : null,
    );
  }
}
