import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/models/user_model.dart';
import 'package:le7e_phart_app/widgets/modern_card.dart';
import 'package:le7e_phart_app/widgets/modern_button.dart';
import 'package:le7e_phart_app/widgets/animated_widgets.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final AuthService _authService = AuthService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  bool _isAuthorized = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    final user = await _authService.getCurrentUser();
    if (user == null || user.role != UserRole.admin) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accès non autorisé. Vous devez être administrateur.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    setState(() => _isAuthorized = true);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    print('AdminPage._loadUsers appelé');
    setState(() => _isLoading = true);
    try {
      final users = await _authService.getAllUsers();
      print('${users.length} utilisateurs reçus dans AdminPage');
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur dans AdminPage._loadUsers: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _changeUserRole(UserModel user, UserRole newRole) async {
    try {
      await _authService.updateUserRole(user.id, newRole);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle mis à jour avec succès')),
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

  Future<void> _deleteUser(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'utilisateur ${user.name} ?'),
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
        await _authService.deleteUser(user.id);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Utilisateur supprimé avec succès')),
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

  Future<void> _approveUser(UserModel user) async {
    try {
      await _authService.approveUser(user.id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur approuvé avec succès')),
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

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboard(context),
          _buildUsersManagement(context),
        ],
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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Membres',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersManagement(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsersList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final adminCount = _users.where((u) => u.role == UserRole.admin).length;
    final userCount = _users.where((u) => u.role == UserRole.user).length;

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
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'STATISTIQUES',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.red,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Total', _users.length.toString(), Icons.people, Colors.red),
              _buildStatItem(context, 'Admins', adminCount.toString(), Icons.admin_panel_settings, Colors.orange),
              _buildStatItem(context, 'Membres', userCount.toString(), Icons.person, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 32,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return ModernCard(
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
                  Icons.flash_on,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'ACTIONS RAPIDES',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.red,
                        letterSpacing: 2,
                        fontSize: 16,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: '🔧 Debug Firebase',
            onPressed: () {
              Navigator.pushNamed(context, '/firebase-debug');
            },
            icon: Icons.bug_report,
            isGradient: true,
            gradientColors: const [Colors.red, Colors.orange],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer le contenu',
            onPressed: () {
              Navigator.pushNamed(context, '/content-management');
            },
            icon: Icons.edit_note,
            isGradient: true,
            gradientColors: const [Colors.orange, Colors.amber],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les événements',
            onPressed: () {
              Navigator.pushNamed(context, '/events-management');
            },
            icon: Icons.event,
            isGradient: true,
            gradientColors: const [Colors.blue, Colors.cyan],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les actualités',
            onPressed: () {
              Navigator.pushNamed(context, '/news-management');
            },
            icon: Icons.newspaper,
            isGradient: true,
            gradientColors: const [Colors.green, Colors.teal],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les vidéos',
            onPressed: () {
              Navigator.pushNamed(context, '/videos-management');
            },
            icon: Icons.video_library,
            isGradient: true,
            gradientColors: const [Colors.purple, Colors.pink],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les émissions',
            onPressed: () {
              Navigator.pushNamed(context, '/emissions-management');
            },
            icon: Icons.tv,
            isGradient: true,
            gradientColors: const [Colors.indigo, Colors.deepPurple],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les films',
            onPressed: () {
              Navigator.pushNamed(context, '/films-management');
            },
            icon: Icons.movie,
            isGradient: true,
            gradientColors: const [Colors.deepOrange, Colors.orangeAccent],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les finances',
            onPressed: () {
              Navigator.pushNamed(context, '/finance-management');
            },
            icon: Icons.euro,
            isGradient: true,
            gradientColors: const [Colors.green, Colors.teal],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Gérer les messages de contact',
            onPressed: () {
              Navigator.pushNamed(context, '/messages-management');
            },
            icon: Icons.mail,
            isGradient: true,
            gradientColors: const [Colors.purple, Colors.pink],
            width: double.infinity,
          ),
          const SizedBox(height: 12),
          ModernButton(
            text: 'Créer un compte admin',
            onPressed: () {
              Navigator.pushNamed(context, '/admin-create');
            },
            icon: Icons.admin_panel_settings,
            isGradient: true,
            gradientColors: const [Colors.grey, Colors.black54],
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    return Column(
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
                Icons.manage_accounts,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'TOUS LES UTILISATEURS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red,
                    letterSpacing: 2,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._users.map((user) => _buildUserCard(context, user)),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    return ModernCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: user.role == UserRole.admin
                        ? [Colors.red, Colors.orange]
                        : [Colors.blue, Colors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: user.role == UserRole.admin
                                ? Colors.red.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role == UserRole.admin ? 'ADMIN' : 'MEMBRE',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: user.role == UserRole.admin
                                      ? Colors.red
                                      : Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: user.isApproved
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isApproved ? 'APPROUVÉ' : 'EN ATTENTE',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: user.isApproved
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inscrit le ${_formatDate(user.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UserRole>(
                  value: user.role,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (newRole) {
                    if (newRole != null && newRole != user.role) {
                      _changeUserRole(user, newRole);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (!user.isApproved)
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _approveUser(user),
                  tooltip: 'Approuver l\'utilisateur',
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(user),
                tooltip: 'Supprimer l\'utilisateur',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
