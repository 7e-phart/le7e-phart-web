class VideoModel {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String thumbnailUrl;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.createdAt,
  });

  factory VideoModel.fromMap(Map<String, dynamic> data, String id) {
    return VideoModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      youtubeUrl: data['youtubeUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'youtubeUrl': youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get youtubeVideoId {
    final regex = RegExp(r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})');
    final match = regex.firstMatch(youtubeUrl);
    return match?.group(1) ?? '';
  }
}
