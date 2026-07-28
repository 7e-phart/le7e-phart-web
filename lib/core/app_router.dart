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
        return MaterialPageRoute(
          builder: (_) => const ContentManagementPage(),
        );
      case '/events-management':
        return MaterialPageRoute(
          builder: (_) => const EventsManagementPage(),
        );
      case '/news-management':
        return MaterialPageRoute(
          builder: (_) => const NewsManagementPage(),
        );
      case '/videos-management':
        return MaterialPageRoute(
          builder: (_) => const VideosManagementPage(),
        );
      case '/firebase-debug':
        return MaterialPageRoute(
          builder: (_) => const FirebaseDebugPage(),
        );
      case '/emissions-management':
        return MaterialPageRoute(
          builder: (_) => const EmissionsManagementPage(),
        );
      case '/films-management':
        return MaterialPageRoute(
          builder: (_) => const FilmsManagementPage(),
        );
      case '/finance-management':
        return MaterialPageRoute(
          builder: (_) => const FinanceManagementPage(),
        );
      case '/messages-management':
        return MaterialPageRoute(
          builder: (_) => const MessagesManagementPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
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
    const RegisterPage(),
    const ContactPage(),
  ];

  final List<String> _titles = [
    'Accueil',
    'Nos émissions',
    'Nos films',
    'Infos',
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
