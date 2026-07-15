class Advocate {
  final int id;
  final String advocateName;

  Advocate({required this.id, required this.advocateName});

  factory Advocate.fromJson(Map<String, dynamic> json) => Advocate(
        id: json["advocateId"] ?? 0,
        advocateName: json["advocateName"] ?? "",
      );
}

class LegalCategory {
  final int id;
  final String categoryName;

  LegalCategory({required this.id, required this.categoryName});

  factory LegalCategory.fromJson(Map<String, dynamic> json) => LegalCategory(
        id: json["id"] ?? 0,
        categoryName: json["category"] ?? "",
      );
}
