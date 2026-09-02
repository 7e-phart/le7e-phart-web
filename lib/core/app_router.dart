import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:le7e_phart_app/features/home/home_page.dart';
import 'package:le7e_phart_app/features/emissions/emissions_page.dart';
import 'package:le7e_phart_app/features/films/films_page.dart';
import 'package:le7e_phart_app/features/about/about_page.dart';
import 'package:le7e_phart_app/features/register/register_page.dart';
import 'package:le7e_phart_app/features/contact/contact_page.dart';
import 'package:le7e_phart_app/features/member/member_space_page.dart';
import 'package:le7e_phart_app/features/office/office_space_page.dart';
import 'package:le7e_phart_app/features/auth/login_page.dart';
import 'package:le7e_phart_app/features/auth/auth_register_page.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:le7e_phart_app/features/admin/admin_page.dart';
import 'package:le7e_phart_app/features/admin/content_management_page.dart';
import 'package:le7e_phart_app/features/admin/events_management_page.dart';
import 'package:le7e_phart_app/features/admin/news_management_page.dart';
import 'package:le7e_phart_app/features/admin/videos_management_page.dart';
import 'package:le7e_phart_app/features/admin/emissions_management_page.dart';
import 'package:le7e_phart_app/features/admin/films_management_page.dart';
import 'package:le7e_phart_app/features/admin/finance_management_page.dart';
import 'package:le7e_phart_app/features/admin/firebase_debug_page.dart';
import 'package:le7e_phart_app/features/admin/messages_management_page.dart';
import 'package:le7e_phart_app/features/admin/partners_management_page.dart';
import 'package:le7e_phart_app/features/admin/articles_management_page.dart';
import 'package:le7e_phart_app/features/media/media_page.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/models/user_model.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/member':
        return MaterialPageRoute(builder: (_) => const MemberSpacePage());
      case '/office':
        return MaterialPageRoute(builder: (_) => const AdminPage());
      case '/register':
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthBloc(authService: AuthService()),
            child: const AuthRegisterPage(),
          ),
        );
      case '/content-management':
        return _buildProtectedRoute(const ContentManagementPage());
      case '/events-management':
        return _buildProtectedRoute(const EventsManagementPage());
      case '/news-management':
        return _buildProtectedRoute(const NewsManagementPage());
      case '/videos-management':
        return _buildProtectedRoute(const VideosManagementPage());
      case '/firebase-debug':
        return _buildProtectedRoute(const FirebaseDebugPage());
      case '/emissions-management':
        return _buildProtectedRoute(const EmissionsManagementPage());
      case '/films-management':
        return _buildProtectedRoute(const FilmsManagementPage());
      case '/finance-management':
        return _buildProtectedRoute(const FinanceManagementPage());
      case '/messages-management':
        return _buildProtectedRoute(const MessagesManagementPage());
      case '/partners-management':
        return _buildProtectedRoute(const PartnersManagementPage());
      case '/articles-management':
        return _buildProtectedRoute(const ArticlesManagementPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }

  static Route<dynamic> _buildProtectedRoute(Widget child) {
    return MaterialPageRoute(
      builder: (context) => ProtectedRoute(child: child),
    );
  }
}

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Si l'état est en cours de chargement, afficher un loader
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si l'utilisateur est authentifié et est admin, afficher la page
        if (state is AuthAuthenticated && state.user.role == UserRole.admin) {
          return child;
        }

        // Si l'utilisateur n'est pas authentifié ou n'est pas admin, rediriger
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/login');
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const EmissionsPage(),
    const FilmsPage(),
    const AboutPage(),
    const MediaPage(),
    const RegisterPage(),
    const ContactPage(),
  ];

  final List<String> _titles = [
    'Accueil',
    'Nos émissions',
    'Nos films',
    'Infos',
    'Média',
    'Adhérer',
    'Nous écrire',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie),
            label: 'Vidéos',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library),
            label: 'Films',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Infos',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: 'Média',
          ),
          NavigationDestination(
            icon: Icon(Icons.app_registration),
            label: 'Adhérer',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail),
            label: 'Contact',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (state.user.role == UserRole.admin) {
                          Navigator.pushNamed(context, '/office');
                        } else {
                          Navigator.pushNamed(context, '/member');
                        }
                      },
                      child: Text(
                        state.user.role == UserRole.admin ? 'Admin' : 'Espace membre',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        context.read<AuthBloc>().add(const LogoutRequested());
                      },
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
