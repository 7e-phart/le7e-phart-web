class ArticleModel {
  final String id;
  final String title;
  final String imageUrl;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> data, String id) {
    return ArticleModel(
      id: id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }
}
