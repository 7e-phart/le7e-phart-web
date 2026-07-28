class ContentModel {
  final String id;
  final String key;
  final String value;
  final DateTime updatedAt;

  ContentModel({
    required this.id,
    required this.key,
    required this.value,
    required this.updatedAt,
  });

  factory ContentModel.fromMap(Map<String, dynamic> data, String id) {
    return ContentModel(
      id: id,
      key: data['key'] ?? '',
      value: data['value'] ?? '',
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
