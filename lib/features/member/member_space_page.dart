import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:le7e_phart_app/models/user_model.dart';
import 'package:le7e_phart_app/services/content_service.dart';
import 'package:le7e_phart_app/models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MemberSpacePage extends StatefulWidget {
  const MemberSpacePage({super.key});

  @override
  State<MemberSpacePage> createState() => _MemberSpacePageState();
}

class _MemberSpacePageState extends State<MemberSpacePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Membre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return IndexedStack(
              index: _currentIndex,
              children: [
                MemberProfilePage(user: state.user),
                MemberActivitiesPage(userId: state.user.id),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Mon profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available),
            label: 'Activités',
          ),
        ],
      ),
    );
  }
}

class MemberProfilePage extends StatelessWidget {
  final UserModel user;

  const MemberProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 24),
          _buildMembershipCard(context),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.role == UserRole.admin ? 'Administrateur' : 'Membre'),
              backgroundColor: user.role == UserRole.admin
                  ? Colors.red.withOpacity(0.2)
                  : Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mon adhésion',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Création du compte'),
              subtitle: Text(_formatDate(user.createdAt)),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Dernière connexion'),
              subtitle: Text(user.lastLogin != null ? _formatDate(user.lastLogin!) : 'Jamais'),
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Statut'),
              subtitle: const Text('Actif'),
              trailing: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class MemberActivitiesPage extends StatefulWidget {
  final String userId;

  const MemberActivitiesPage({super.key, required this.userId});

  @override
  State<MemberActivitiesPage> createState() => _MemberActivitiesPageState();
}

class _MemberActivitiesPageState extends State<MemberActivitiesPage> {
  final ContentService _contentService = ContentService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<EventModel> _events = [];
  Set<String> _registeredEventIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final events = await _contentService.getEvents();
      
      // Récupérer les inscriptions de l'utilisateur
      final registrationsSnapshot = await _firestore
          .collection('event_registrations')
          .where('userId', isEqualTo: widget.userId)
          .get();
      
      final registeredIds = registrationsSnapshot.docs
          .map((doc) => doc.data()['eventId'] as String)
          .toSet();
      
      setState(() {
        _events = events;
        _registeredEventIds = registeredIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerForEvent(String eventId) async {
    try {
      await _firestore.collection('event_registrations').add({
        'eventId': eventId,
        'userId': widget.userId,
        'registeredAt': DateTime.now().millisecondsSinceEpoch,
      });
      setState(() {
        _registeredEventIds.add(eventId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unregisterFromEvent(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('event_registrations')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: widget.userId)
          .get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      setState(() {
        _registeredEventIds.remove(eventId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Désinscription réussie'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Événements disponibles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_events.isEmpty)
              const Center(
                child: Text('Aucun événement disponible pour le moment'),
              )
            else
              ..._events.map((event) => _buildActivityCard(
                    context,
                    event,
                    _registeredEventIds.contains(event.id),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    EventModel event,
    bool isRegistered,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(isRegistered ? Icons.check : Icons.event),
        ),
        title: Text(event.title),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy').format(event.date)}\n${event.location}',
        ),
        isThreeLine: true,
        trailing: isRegistered
            ? const Chip(
                label: Text('Inscrit'),
                backgroundColor: Colors.green,
              )
            : OutlinedButton(
                onPressed: () => _registerForEvent(event.id),
                child: const Text('S\'inscrire'),
              ),
        onTap: isRegistered
            ? () => _unregisterFromEvent(event.id)
            : null,
      ),
    );
  }
}
