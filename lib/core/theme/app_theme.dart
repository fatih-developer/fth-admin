import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFFF6B00), // Turuncu
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF6B00),
        secondary: Colors.orange,
        surface: Color(0xFF121212),
        surfaceContainerHighest: Color(0xFF121212),
        onSurface: Colors.white,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B00),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
