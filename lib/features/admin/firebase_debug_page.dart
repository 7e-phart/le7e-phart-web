import 'package:flutter/material.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/event_model.dart';
import 'package:le7e_phart_app/models/news_model.dart';

class FirebaseDebugPage extends StatefulWidget {
  const FirebaseDebugPage({super.key});

  @override
  State<FirebaseDebugPage> createState() => _FirebaseDebugPageState();
}

class _FirebaseDebugPageState extends State<FirebaseDebugPage> {
  final AuthService _authService = AuthService();
  final ContentService _contentService = ContentService();
  List<String> _logs = [];
  bool _isTesting = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String()}: $message');
    });
    print(message);
  }

  Future<void> _testFirebaseConnection() async {
    setState(() {
      _logs.clear();
      _isTesting = true;
    });

    _addLog('=== DÉBUT DU TEST FIREBASE ===');

    // Test 1: Initialisation
    _addLog('Test 1: Initialisation Firebase');
    try {
      _addLog('AuthService initialisé: ${_authService != null}');
      _addLog('ContentService initialisé: ${_contentService != null}');
    } catch (e) {
      _addLog('ERREUR Initialisation: $e');
    }

    // Test 2: Récupération des utilisateurs
    _addLog('\nTest 2: Récupération des utilisateurs depuis Firestore');
    try {
      final users = await _authService.getAllUsers();
      _addLog('SUCCÈS: ${users.length} utilisateurs récupérés');
      for (var user in users) {
        _addLog('  - ${user.name} (${user.email}) - Rôle: ${user.role}');
      }
    } catch (e) {
      _addLog('ERREUR Récupération utilisateurs: $e');
    }

    // Test 3: Récupération des événements
    _addLog('\nTest 3: Récupération des événements depuis Firestore');
    try {
      final events = await _contentService.getEvents();
      _addLog('SUCCÈS: ${events.length} événements récupérés');
      for (var event in events) {
        _addLog('  - ${event.title} (${event.date.toIso8601String()})');
      }
    } catch (e) {
      _addLog('ERREUR Récupération événements: $e');
    }

    // Test 4: Récupération des actualités
    _addLog('\nTest 4: Récupération des actualités depuis Firestore');
    try {
      final news = await _contentService.getNews();
      _addLog('SUCCÈS: ${news.length} actualités récupérées');
      for (var item in news) {
        _addLog('  - ${item.title} (${item.date.toIso8601String()})');
      }
    } catch (e) {
      _addLog('ERREUR Récupération actualités: $e');
    }

    // Test 5: Ajout d'un événement de test
    _addLog('\nTest 5: Ajout d\'un événement de test');
    try {
      final testEvent = EventModel(
        id: '',
        title: 'Événement de test',
        description: 'Ceci est un événement de test pour vérifier Firestore',
        location: 'Test Location',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _contentService.addEvent(testEvent);
      _addLog('SUCCÈS: Événement de test ajouté');
      
      // Vérifier qu'il a été ajouté
      final events = await _contentService.getEvents();
      _addLog('Vérification: ${events.length} événements après ajout');
    } catch (e) {
      _addLog('ERREUR Ajout événement: $e');
    }

    // Test 6: Ajout d'une actualité de test
    _addLog('\nTest 6: Ajout d\'une actualité de test');
    try {
      final testNews = NewsModel(
        id: '',
        title: 'Actualité de test',
        content: 'Ceci est une actualité de test pour vérifier Firestore',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _contentService.addNews(testNews);
      _addLog('SUCCÈS: Actualité de test ajoutée');
      
      // Vérifier qu'elle a été ajoutée
      final news = await _contentService.getNews();
      _addLog('Vérification: ${news.length} actualités après ajout');
    } catch (e) {
      _addLog('ERREUR Ajout actualité: $e');
    }

    _addLog('\n=== FIN DU TEST FIREBASE ===');
    setState(() {
      _isTesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Firebase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testFirebaseConnection,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isTesting ? null : _testFirebaseConnection,
              icon: _isTesting 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.bug_report),
              label: Text(_isTesting ? 'Test en cours...' : 'Lancer le test Firebase'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text('Cliquez sur "Lancer le test Firebase" pour commencer'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final isError = log.contains('ERREUR');
                      final isSuccess = log.contains('SUCCÈS');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            color: isError 
                                ? Colors.red 
                                : isSuccess 
                                    ? Colors.green 
                                    : Colors.black87,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
