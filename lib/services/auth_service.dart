import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/content_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _protectedAdminEmail = 'singedrummer@gmail.com';
  firebase_auth.FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  AuthService() {
    try {
      _auth = firebase_auth.FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
      print('AuthService: Firebase initialisé avec succès');
    } catch (e) {
      debugPrint('Firebase non disponible: $e');
      print('AuthService: Erreur d\'initialisation Firebase: $e');
      _isFirebaseAvailable = false;
    }
  }

  firebase_auth.User? get currentUser => _auth?.currentUser;
  Stream<firebase_auth.User?>? get authStateChanges => 
      _isFirebaseAvailable ? _auth?.authStateChanges() : null;

  Future<UserModel?> getCurrentUser() async {
    print('AuthService.getCurrentUser appelé');
    if (!_isFirebaseAvailable) {
      print('Firebase non disponible dans getCurrentUser');
      return null;
    }
    
    final user = _auth?.currentUser;
    if (user == null) {
      print('Aucun utilisateur Firebase connecté');
      return null;
    }
    print('Utilisateur Firebase connecté: ${user.uid}, email: ${user.email}');

    final doc = await _firestore?.collection('users').doc(user.uid).get();
    if (doc == null || !doc.exists) {
      print('Document utilisateur non trouvé dans Firestore pour UID: ${user.uid}');
      return null;
    }
    print('Document utilisateur trouvé: ${doc.data()}');

    final userModel = UserModel.fromMap(doc.data()!, doc.id);
    print('UserModel créé: ${userModel.name}, rôle: ${userModel.role}');
    return userModel;
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.user,
  }) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isApproved: false,
      );

      try {
        await _firestore!
            .collection('users')
            .doc(user.id)
            .set(user.toMap());
      } catch (e) {
        // Si l'écriture Firestore échoue, supprimer l'utilisateur Firebase Auth
        print('Erreur lors de l\'écriture Firestore, suppression de l\'utilisateur Firebase Auth: $e');
        await userCredential.user?.delete();
        throw Exception('Erreur lors de la création du compte: $e');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    print('AuthService.signIn appelé avec email: $email');
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }

    try {
      print('Tentative de connexion Firebase...');
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Connexion Firebase réussie, UID: ${userCredential.user!.uid}');

      print('Mise à jour du lastLogin dans Firestore...');
      try {
        await _firestore!
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLogin': DateTime.now().toIso8601String()});
      } catch (e) {
        print('Erreur lors de la mise à jour de lastLogin (non bloquant): $e');
      }

      print('Récupération des données utilisateur depuis Firestore...');
      final user = await getCurrentUser();
      print('Utilisateur récupéré: ${user?.name}, rôle: ${user?.role}, approuvé: ${user?.isApproved}');

      if (user != null && email == _protectedAdminEmail) {
        print('Utilisateur protégé détecté, forçage du rôle admin et approbation');
        await _firestore!
            .collection('users')
            .doc(user.id)
            .update({
              'role': UserRole.admin.toString().split('.').last,
              'isApproved': true,
            });
        final updatedUser = await getCurrentUser();
        return updatedUser;
      }

      if (user != null && !user.isApproved && user.role != UserRole.admin) {
        print('Utilisateur non approuvé et non admin, déconnexion complète');
        await _auth!.signOut();
        await _auth!.signOut();
        throw Exception('Votre compte est en attente de validation par le staff. Vous recevrez une notification quand il sera validé.');
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Erreur Firebase Auth: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      await _auth?.signOut();
    }
  }

  Future<void> resetPassword(String email) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _auth!.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }

    try {
      final userDoc = await _firestore!.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final userEmail = userData?['email'] as String?;
        if (userEmail == _protectedAdminEmail) {
          throw Exception('Impossible de modifier le rôle de cet utilisateur');
        }
      }

      await _firestore!.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du rôle: $e');
    }
  }

  Future<void> approveUser(String userId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }

    try {
      await _firestore!.collection('users').doc(userId).update({
        'isApproved': true,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'approbation de l\'utilisateur: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    print('AuthService.getAllUsers appelé');
    if (!_isFirebaseAvailable) {
      print('Firebase non disponible dans getAllUsers');
      throw Exception('Firebase non disponible');
    }
    
    try {
      print('Récupération des utilisateurs depuis Firestore...');
      final snapshot = await _firestore!.collection('users').get();
      print('Snapshot reçu: ${snapshot.docs.length} documents');
      
      final users = snapshot.docs
          .map((doc) {
            print('Document: ${doc.id}, données: ${doc.data()}');
            return UserModel.fromMap(doc.data(), doc.id);
          })
          .toList();
      
      print('${users.length} utilisateurs récupérés');
      return users;
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      throw Exception('Erreur lors de la récupération des utilisateurs: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: $e');
    }
  }

  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Format d\'email invalide.';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }

  // Gestion du contenu de l'application
  Future<String> getContent(String key) async {
    if (!_isFirebaseAvailable) {
      return _getDefaultContent(key);
    }
    
    try {
      final doc = await _firestore!.collection('content').doc(key).get();
      if (doc.exists) {
        return doc.data()!['value'] ?? _getDefaultContent(key);
      }
      return _getDefaultContent(key);
    } catch (e) {
      return _getDefaultContent(key);
    }
  }

  Future<void> setContent(String key, String value) async {
    if (!_isFirebaseAvailable) {
      throw Exception('Firebase non disponible');
    }
    
    try {
      await _firestore!.collection('content').doc(key).set({
        'key': key,
        'value': value,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du contenu: $e');
    }
  }

  Future<Map<String, String>> getAllContent() async {
    if (!_isFirebaseAvailable) {
      return _getDefaultContentMap();
    }
    
    try {
      final snapshot = await _firestore!.collection('content').get();
      final Map<String, String> content = {};
      for (var doc in snapshot.docs) {
        content[doc.data()['key']] = doc.data()['value'];
      }
      return content.isNotEmpty ? content : _getDefaultContentMap();
    } catch (e) {
      return _getDefaultContentMap();
    }
  }

  String _getDefaultContent(String key) {
    final defaults = _getDefaultContentMap();
    return defaults[key] ?? key;
  }

  Map<String, String> _getDefaultContentMap() {
    return {
      'home_title': 'Accueil',
      'emissions_title': 'Nos émissions',
      'films_title': 'Nos films',
      'about_title': 'Qui sommes-nous ?',
      'register_title': 'S\'inscrire',
      'contact_title': 'Nous écrire',
      'home_welcome': 'Bienvenue au 7e Phart',
      'home_subtitle': 'Association de cinéma de Dunkerque',
      'about_description': 'Le 7e Phart est une association de cinéma...',
    };
  }

  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.role == UserRole.admin;
  }
}
