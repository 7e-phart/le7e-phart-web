import 'package:flutter/material.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/event_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/modern_button.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsManagementPage extends StatefulWidget {
  const EventsManagementPage({super.key});

  @override
  State<EventsManagementPage> createState() => _EventsManagementPageState();
}

class _EventsManagementPageState extends State<EventsManagementPage> {
  final ContentService _contentService = ContentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<EventModel> _events = [];
  Map<String, List<Map<String, dynamic>>> _eventRegistrations = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    print('EventsManagementPage._loadEvents appelé');
    setState(() => _isLoading = true);
    try {
      final events = await _contentService.getEvents();
      print('${events.length} événements reçus');
      
      // Charger les inscriptions pour chaque événement
      final registrations = <String, List<Map<String, dynamic>>>{};
      for (var event in events) {
        final snapshot = await _firestore
            .collection('event_registrations')
            .where('eventId', isEqualTo: event.id)
            .get();
        
        final usersData = <Map<String, dynamic>>[];
        for (var doc in snapshot.docs) {
          final userId = doc.data()['userId'] as String;
          final userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists && userDoc.data() != null) {
            final userData = userDoc.data()!;
            usersData.add({
              'id': userId,
              'name': userData['name'] ?? 'Inconnu',
              'email': userData['email'] ?? '',
              'registeredAt': doc.data()['registeredAt'],
            });
          }
        }
        registrations[event.id] = usersData;
      }
      
      setState(() {
        _events = events;
        _eventRegistrations = registrations;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans _loadEvents: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteEvent(EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'événement "${event.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _contentService.deleteEvent(event.id);
        await _loadEvents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Événement supprimé avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: StaggeredAnimationList(
                  children: [
                    _buildInfoCard(context),
                    const SizedBox(height: 24),
                    ..._events.map((event) => _buildEventCard(context, event)),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return ModernCard(
      withGradient: true,
      gradientColors: [
        Colors.red.withOpacity(0.1),
        Colors.orange.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'ÉVÉNEMENTS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_events.length} événement(s) enregistré(s)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                event.location,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(event.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_eventRegistrations[event.id]?.length ?? 0} inscrit(s)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.people, color: Colors.green),
                    onPressed: () => _showRegistrationsDialog(event),
                    tooltip: 'Voir les inscrits',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEventDialog(event: event),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEvent(event),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEventDialog({EventModel? event}) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    DateTime selectedDate = event?.date ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Nouvel événement' : 'Modifier l\'événement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Date et heure'),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
                      selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        time.hour,
                        time.minute,
                      );
                      setState(() {});
                    }
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('Bouton Ajouter/Modifier cliqué');
              if (titleController.text.isEmpty) {
                print('Erreur: Titre vide');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un titre')),
                );
                return;
              }

              print('Création de l\'EventModel avec: ${titleController.text}');
              final newEvent = EventModel(
                id: event?.id ?? '',
                title: titleController.text,
                description: descriptionController.text,
                location: locationController.text,
                date: selectedDate,
                createdAt: event?.createdAt ?? DateTime.now(),
              );

              print('Tentative d\'ajout à Firestore...');
              try {
                if (event == null) {
                  print('Appel de addEvent...');
                  await _contentService.addEvent(newEvent);
                  print('addEvent terminé');
                } else {
                  print('Appel de updateEvent...');
                  await _contentService.updateEvent(event.id, newEvent);
                  print('updateEvent terminé');
                }
                print('Rechargement des événements...');
                await _loadEvents();
                print('Événements rechargés');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(event == null ? 'Événement ajouté' : 'Événement modifié'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                print('ERREUR lors de l\'ajout: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: Text(event == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _showRegistrationsDialog(EventModel event) {
    final registrations = _eventRegistrations[event.id] ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inscrits à "${event.title}"'),
        content: SizedBox(
          width: double.maxFinite,
          child: registrations.isEmpty
              ? const Center(
                  child: Text('Aucun inscrit pour cet événement'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: registrations.length,
                  itemBuilder: (context, index) {
                    final user = registrations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user['name'][0].toUpperCase()),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: Text(
                        user['registeredAt'] != null
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(user['registeredAt']))
                            : '',
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
