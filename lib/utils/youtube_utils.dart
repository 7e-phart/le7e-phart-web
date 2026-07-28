class YoutubeUtils {
  /// Extrait l'ID vidéo YouTube depuis une URL YouTube
  /// Supporte différents formats d'URL YouTube :
  /// - https://www.youtube.com/watch?v=VIDEO_ID
  /// - https://youtu.be/VIDEO_ID
  /// - https://www.youtube.com/embed/VIDEO_ID
  /// - https://www.youtube.com/v/VIDEO_ID
  /// - https://www.youtube.com/shorts/VIDEO_ID
  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    
    // Nettoyer l'URL
    url = url.trim();
    
    // Pattern pour les différents formats d'URL YouTube
    final patterns = [
      // Standard watch URL: https://www.youtube.com/watch?v=VIDEO_ID
      RegExp(r'[?&]v=([^&]+)'),
      // Short URL: https://youtu.be/VIDEO_ID
      RegExp(r'youtu\.be/([^/?&]+)'),
      // Embed URL: https://www.youtube.com/embed/VIDEO_ID
      RegExp(r'embed/([^/?&]+)'),
      // v URL: https://www.youtube.com/v/VIDEO_ID
      RegExp(r'/v/([^/?&]+)'),
      // Shorts URL: https://www.youtube.com/shorts/VIDEO_ID
      RegExp(r'shorts/([^/?&]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        final videoId = match.group(1);
        if (videoId != null && videoId.isNotEmpty) {
          // Retirer les paramètres supplémentaires si présents
          final cleanId = videoId.split('?')[0].split('&')[0];
          if (cleanId.length >= 11) {
            return cleanId;
          }
        }
      }
    }
    
    return null;
  }
  
  /// Génère l'URL de la miniature YouTube depuis une URL YouTube
  /// Retourne null si l'URL n'est pas valide ou si l'ID vidéo ne peut pas être extrait
  static String? getThumbnailUrl(String youtubeUrl) {
    final videoId = extractVideoId(youtubeUrl);
    if (videoId == null) return null;
    
    // Utilise la miniature de haute qualité (hqdefault)
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }
  
  /// Vérifie si une URL est une URL YouTube valide
  static bool isYoutubeUrl(String url) {
    return extractVideoId(url) != null;
  }
}
