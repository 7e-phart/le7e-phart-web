import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:le7e_phart_app/core/app_router.dart';
import 'package:le7e_phart_app/core/app_theme.dart';
import 'package:le7e_phart_app/features/auth/auth_bloc.dart';
import 'package:le7e_phart_app/features/home/home_bloc.dart';
import 'package:le7e_phart_app/features/members/members_bloc.dart';
import 'package:le7e_phart_app/features/finance/finance_bloc.dart';
import 'package:le7e_phart_app/services/auth_service.dart';
import 'package:le7e_phart_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase est optionnel - l'application fonctionnera même sans
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé avec succès');
  } catch (e) {
    print('Firebase non disponible: $e');
  }
  
  final authService = AuthService();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authService: authService)..add(const CheckAuthStatus()),
        ),
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => MembersBloc()),
        BlocProvider(create: (_) => FinanceBloc()),
      ],
      child: MaterialApp(
        title: 'Le 7e Phart',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/',
      ),
    );
  }
}
