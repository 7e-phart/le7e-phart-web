import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageUploadService {
  // Service d'upload d'images compatible Flutter Web
  // Utilise imgbb.com comme service d'upload gratuit
  
  static const String _imgbbApiKey = 'YOUR_IMGBB_API_KEY'; // À remplacer par votre clé API
  
  /// Upload une image sur imgbb.com et retourne l'URL publique
  static Future<String?> uploadImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      // Convertir les bytes en base64
      final base64Image = base64Encode(imageBytes);
      
      // Créer la requête multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload'),
      );
      
      request.fields['key'] = _imgbbApiKey;
      request.fields['image'] = base64Image;
      request.fields['name'] = fileName;
      
      // Envoyer la requête
      final response = await request.send();
      final responseBody = await response.stream.toBytes();
      final responseString = utf8.decode(responseBody);
      
      if (response.statusCode == 200) {
        // Parser la réponse JSON
        final data = json.decode(responseString);
        if (data['success'] == true && data['data'] != null) {
          return data['data']['url'];
        }
      } else {
        print('Erreur upload imgbb: ${response.statusCode} - $responseString');
      }
    } catch (e) {
      print('Exception upload imgbb: $e');
    }
    return null;
  }
  
  /// Supprime une image (non implémenté pour imgbb)
  static Future<void> deleteImage(String imageUrl) async {
    // imgbb ne permet pas la suppression via API gratuitement
    print('Suppression d\'image non disponible avec imgbb gratuit');
  }
}
