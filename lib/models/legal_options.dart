class LegalOption {
  final String id;
  final String label;
  final String? value;
  final String? key;
  final String? fileName;

  LegalOption({
    required this.id,
    required this.label,
    this.value,
    this.key,
    this.fileName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LegalOption &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LegalOption(id: $id, label: $label)';
}
