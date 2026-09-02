class FilmModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? youtubeUrl;
  final String category;
  final DateTime createdAt;

  FilmModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.youtubeUrl,
    required this.category,
    required this.createdAt,
  });

  factory FilmModel.fromMap(Map<String, dynamic> data, String id) {
    return FilmModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      youtubeUrl: data['youtubeUrl'],
      category: data['category'] ?? 'film',
      createdAt: data['createdAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'youtubeUrl': youtubeUrl,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
