import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/news_model.dart';
import '../models/video_model.dart';
import '../models/emission_model.dart';
import '../models/film_model.dart';
import '../models/transaction_model.dart';
import '../models/contact_message_model.dart';

class ContentService {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  ContentService() {
    try {
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      print('ContentService: Firebase initialisé avec succès');
    } catch (e) {
      print('ContentService: Erreur d\'initialisation Firebase: $e');
      _isFirebaseAvailable = false;
    }
  }

  // Gestion des événements
  Future<List<EventModel>> getEvents() async {
    print('ContentService.getEvents appelé');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Récupération des événements depuis Firestore...');
      final snapshot = await _firestore!
          .collection('events')
          .orderBy('date', descending: true)
          .get();
      
      print('ContentService: ${snapshot.docs.length} événements récupérés');
      return snapshot.docs
          .map((doc) {
            print('ContentService: Événement - ${doc.id}: ${doc.data()}');
            return EventModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    } catch (e) {
      print('ContentService: Erreur lors de la récupération des événements: $e');
      throw Exception('Erreur lors de la récupération des événements: $e');
    }
  }

  Future<void> addEvent(EventModel event) async {
    print('ContentService.addEvent appelé avec: ${event.toMap()}');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Ajout de l\'événement à Firestore...');
      final docRef = await _firestore!.collection('events').add(event.toMap());
      print('ContentService: Événement ajouté avec ID: ${docRef.id}');
    } catch (e) {
      print('ContentService: Erreur lors de l\'ajout de l\'événement: $e');
      throw Exception('Erreur lors de l\'ajout de l\'événement: $e');
    }
  }

  Future<void> updateEvent(String eventId, EventModel event) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('events').doc(eventId).update(event.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement: $e');
    }
  }

  // Gestion des actualités
  Future<List<NewsModel>> getNews() async {
    print('ContentService.getNews appelé');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      final snapshot = await _firestore!
          .collection('news')
          .orderBy('date', descending: true)
          .get();
      
      final twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
      
      return snapshot.docs
          .map((doc) => NewsModel.fromMap(doc.data(), doc.id))
          .where((news) => news.date.isAfter(twoMonthsAgo))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des actualités: $e');
    }
  }

  Future<void> addNews(NewsModel news) async {
    print('ContentService.addNews appelé avec: ${news.toMap()}');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Ajout de l\'actualité à Firestore...');
      final docRef = await _firestore!.collection('news').add(news.toMap());
      print('ContentService: Actualité ajoutée avec ID: ${docRef.id}');
    } catch (e) {
      print('ContentService: Erreur lors de l\'ajout de l\'actualité: $e');
      throw Exception('Erreur lors de l\'ajout de l\'actualité: $e');
    }
  }

  Future<void> updateNews(String newsId, NewsModel news) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('news').doc(newsId).update(news.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'actualité: $e');
    }
  }

  Future<void> deleteNews(String newsId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('news').doc(newsId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'actualité: $e');
    }
  }

  // Gestion des vidéos
  Future<List<VideoModel>> getVideos() async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      final snapshot = await _firestore!
          .collection('videos')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => VideoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des vidéos: $e');
    }
  }

  Future<void> addVideo(VideoModel video) async {
    print('ContentService.addVideo appelé avec: ${video.toMap()}');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Ajout de la vidéo à Firestore...');
      final docRef = await _firestore!.collection('videos').add(video.toMap());
      print('ContentService: Vidéo ajoutée avec ID: ${docRef.id}');
    } catch (e) {
      print('ContentService: Erreur lors de l\'ajout de la vidéo: $e');
      throw Exception('Erreur lors de l\'ajout de la vidéo: $e');
    }
  }

  Future<void> updateVideo(String videoId, VideoModel video) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('videos').doc(videoId).update(video.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la vidéo: $e');
    }
  }

  Future<void> deleteVideo(String videoId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('videos').doc(videoId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la vidéo: $e');
    }
  }

  // Gestion des émissions
  Future<List<EmissionModel>> getEmissions() async {
    print('ContentService.getEmissions appelé');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Récupération des émissions depuis Firestore...');
      final snapshot = await _firestore!
          .collection('emissions')
          .orderBy('createdAt', descending: true)
          .get();
      
      print('ContentService: ${snapshot.docs.length} émissions récupérées');
      return snapshot.docs
          .map((doc) {
            print('ContentService: Émission - ${doc.id}: ${doc.data()}');
            return EmissionModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    } catch (e) {
      print('ContentService: Erreur lors de la récupération des émissions: $e');
      throw Exception('Erreur lors de la récupération des émissions: $e');
    }
  }

  Future<void> addEmission(EmissionModel emission) async {
    print('ContentService.addEmission appelé avec: ${emission.toMap()}');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Ajout de l\'émission à Firestore...');
      final docRef = await _firestore!.collection('emissions').add(emission.toMap());
      print('ContentService: Émission ajoutée avec ID: ${docRef.id}');
    } catch (e) {
      print('ContentService: Erreur lors de l\'ajout de l\'émission: $e');
      throw Exception('Erreur lors de l\'ajout de l\'émission: $e');
    }
  }

  Future<void> updateEmission(String emissionId, EmissionModel emission) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('emissions').doc(emissionId).update(emission.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la modification de l\'émission: $e');
    }
  }

  Future<void> deleteEmission(String emissionId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('emissions').doc(emissionId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'émission: $e');
    }
  }

  // Gestion des films
  Future<List<FilmModel>> getFilms() async {
    print('ContentService.getFilms appelé');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Récupération des films depuis Firestore...');
      final snapshot = await _firestore!
          .collection('films')
          .orderBy('createdAt', descending: true)
          .get();
      
      print('ContentService: ${snapshot.docs.length} films récupérés');
      return snapshot.docs
          .map((doc) {
            print('ContentService: Film - ${doc.id}: ${doc.data()}');
            return FilmModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    } catch (e) {
      print('ContentService: Erreur lors de la récupération des films: $e');
      throw Exception('Erreur lors de la récupération des films: $e');
    }
  }

  Future<void> addFilm(FilmModel film) async {
    print('ContentService.addFilm appelé avec: ${film.toMap()}');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Ajout du film à Firestore...');
      final docRef = await _firestore!.collection('films').add(film.toMap());
      print('ContentService: Film ajouté avec ID: ${docRef.id}');
    } catch (e) {
      print('ContentService: Erreur lors de l\'ajout du film: $e');
      throw Exception('Erreur lors de l\'ajout du film: $e');
    }
  }

  Future<void> updateFilm(String filmId, FilmModel film) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('films').doc(filmId).update(film.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la modification du film: $e');
    }
  }

  Future<void> deleteFilm(String filmId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('films').doc(filmId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du film: $e');
    }
  }

  // Gestion des transactions financières
  Future<List<TransactionModel>> getTransactions() async {
    print('ContentService.getTransactions appelé');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Récupération des transactions depuis Firestore...');
      final snapshot = await _firestore!
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();
      
      print('ContentService: ${snapshot.docs.length} transactions récupérées');
      return snapshot.docs
          .map((doc) {
            print('ContentService: Transaction - ${doc.id}: ${doc.data()}');
            return TransactionModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    } catch (e) {
      print('ContentService: Erreur lors de la récupération des transactions: $e');
      throw Exception('Erreur lors de la récupération des transactions: $e');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    print('ContentService.addTransaction appelé avec: ${transaction.toMap()}');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Ajout de la transaction à Firestore...');
      final docRef = await _firestore!.collection('transactions').add(transaction.toMap());
      print('ContentService: Transaction ajoutée avec ID: ${docRef.id}');
    } catch (e) {
      print('ContentService: Erreur lors de l\'ajout de la transaction: $e');
      throw Exception('Erreur lors de l\'ajout de la transaction: $e');
    }
  }

  Future<void> updateTransaction(String transactionId, TransactionModel transaction) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('transactions').doc(transactionId).update(transaction.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la modification de la transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la transaction: $e');
    }
  }

  // Gestion des messages de contact
  Future<List<ContactMessageModel>> getContactMessages() async {
    print('ContentService.getContactMessages appelé');
    if (!_isFirebaseAvailable) {
      print('ContentService: Firebase non disponible');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('ContentService: Récupération des messages de contact depuis Firestore...');
      final snapshot = await _firestore!
          .collection('contact_messages')
          .orderBy('createdAt', descending: true)
          .get();
      
      print('ContentService: ${snapshot.docs.length} messages récupérés');
      return snapshot.docs
          .map((doc) {
            print('ContentService: Message - ${doc.id}: ${doc.data()}');
            return ContactMessageModel.fromMap(doc.data(), doc.id);
          })
          .toList();
    } catch (e) {
      print('ContentService: Erreur lors de la récupération des messages: $e');
      throw Exception('Erreur lors de la récupération des messages: $e');
    }
  }

  Future<void> addContactMessage(ContactMessageModel message) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('contact_messages').add(message.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du message: $e');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('contact_messages').doc(messageId).update({'isRead': true});
    } catch (e) {
      throw Exception('Erreur lors du marquage du message comme lu: $e');
    }
  }

  Future<void> deleteContactMessage(String messageId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('contact_messages').doc(messageId).delete();
    } catch (e) {
      throw Exception('Erreur lors de the suppression du message: $e');
    }
  }
}
