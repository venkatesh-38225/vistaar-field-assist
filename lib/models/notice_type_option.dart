class NoticeTypeOption {
  final String noticeType;
  final List<String> subTypes;

  NoticeTypeOption({
    required this.noticeType,
    required this.subTypes,
  });

  factory NoticeTypeOption.fromJson(Map<String, dynamic> json) {
    return NoticeTypeOption(
      noticeType: json['noticeType'] as String,
      subTypes: (json['subTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeType': noticeType,
      'subTypes': subTypes,
    };
  }

  @override
  String toString() => 'NoticeTypeOption(noticeType: $noticeType, subTypes: $subTypes)';
}
