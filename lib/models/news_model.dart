class NewsModel {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final DateTime createdAt;
  final String? imageUrl;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    this.imageUrl,
  });

  factory NewsModel.fromMap(Map<String, dynamic> data, String id) {
    return NewsModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
