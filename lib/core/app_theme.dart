import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF020913);
  static const Color purpleAccent = Color(0xFF4f249a);
  static const Color lightBeige = Color(0xFFf2efe9);
  static const Color gold = Color(0xFFcea035);
  static const Color gray = Color(0xFF7e8186);
  static const Color redAccent = Color(0xFF9c1a1a);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.light,
        primary: gold,
        secondary: purpleAccent,
        background: lightBeige,
        surface: lightBeige,
        error: redAccent,
      ),
      scaffoldBackgroundColor: lightBeige,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: lightBeige,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightBeige,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'BebasNeue',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'BebasNeue',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displaySmall: TextStyle(
          fontFamily: 'BebasNeue',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'BebasNeue',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'BebasNeue',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'BebasNeue',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Montserrat',
          color: darkBackground,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: darkBackground,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: darkBackground,
          letterSpacing: 0.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          color: gray,
          letterSpacing: 0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightBeige,
        indicatorColor: gold.withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(color: darkBackground),
        ),
        iconTheme: MaterialStateProperty.all(
          const IconThemeData(color: darkBackground),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        primary: gold,
        secondary: purpleAccent,
        background: darkBackground,
        surface: const Color(0xFF1a1a2e),
        error: redAccent,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: lightBeige,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1a1a2e),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: darkBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'BebasNeue',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displayMedium: TextStyle(
          fontFamily: 'BebasNeue',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        displaySmall: TextStyle(
          fontFamily: 'BebasNeue',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'BebasNeue',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'BebasNeue',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'BebasNeue',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Montserrat',
          color: lightBeige,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Montserrat',
          color: lightBeige,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Montserrat',
          color: lightBeige,
          letterSpacing: 0.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Montserrat',
          color: gray,
          letterSpacing: 0.5,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBackground,
        indicatorColor: gold.withOpacity(0.3),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(color: lightBeige),
        ),
        iconTheme: MaterialStateProperty.all(
          const IconThemeData(color: lightBeige),
        ),
      ),
    );
  }
}
