class DownloadNoticeResponse {
  final bool success;
  final DownloadNoticeData? data;
  final String message;

  DownloadNoticeResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory DownloadNoticeResponse.fromJson(Map<String, dynamic> json) {
    return DownloadNoticeResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DownloadNoticeData.fromJson(json['data']) : null,
      message: json['message'] ?? "",
    );
  }
}

class DownloadNoticeData {
  final String lan;
  final String noticeType;
  final String subType;
  final NoticeFileData? file;

  DownloadNoticeData({
    required this.lan,
    required this.noticeType,
    required this.subType,
    this.file,
  });

  factory DownloadNoticeData.fromJson(Map<String, dynamic> json) {
    return DownloadNoticeData(
      lan: json['lan']?.toString() ?? "",
      noticeType: json['noticeType']?.toString() ?? "",
      subType: json['subType']?.toString() ?? "",
      file: json['file'] != null ? NoticeFileData.fromJson(json['file']) : null,
    );
  }
}

class NoticeFileData {
  final String? fileName;
  final String? base64;

  NoticeFileData({this.fileName, this.base64});

  factory NoticeFileData.fromJson(Map<String, dynamic> json) {
    return NoticeFileData(
      fileName: json['fileName']?.toString(),
      base64: json['base64']?.toString(),
    );
  }
}
