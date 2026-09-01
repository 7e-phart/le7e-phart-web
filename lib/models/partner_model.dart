class PartnerModel {
  final String id;
  final String name;
  final String logoUrl;
  final String websiteUrl;
  final DateTime createdAt;

  PartnerModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.websiteUrl,
    required this.createdAt,
  });

  factory PartnerModel.fromMap(Map<String, dynamic> data, String id) {
    return PartnerModel(
      id: id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      websiteUrl: data['websiteUrl'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'createdAt': createdAt,
    };
  }
}
