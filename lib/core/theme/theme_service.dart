import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class ThemeService {
  static bool isDarkMode = true;
  
  static Future<void> initTheme() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    isDarkMode = savedThemeMode?.isDark ?? true;
  }
  
  static Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
  }
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFFFF6B00),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFFF6B00),
        secondary: Colors.orange,
        surface: Colors.white,
        background: Colors.grey[100]!,
        onBackground: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        width: 250,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFFF6B00),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B00),
        secondary: Colors.orange,
        surface: Color(0xFF121212),
        background: Color(0xFF121212),
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.black,
        width: 250,
      ),
    );
  }
}
