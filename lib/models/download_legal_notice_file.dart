class DownloadLegalNoticeFile {
  final String? category;
  final String? fileName;
  final String? base64;

  DownloadLegalNoticeFile({
    this.category,
    this.fileName,
    this.base64,
  });

  factory DownloadLegalNoticeFile.fromJson(Map<String, dynamic> json) {
    return DownloadLegalNoticeFile(
      category: json['category'],
      fileName: json['fileName'],
      base64: json['base64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'fileName': fileName,
      'base64': base64,
    };
  }
}
