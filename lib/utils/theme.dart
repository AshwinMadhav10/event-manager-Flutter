import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color accentColor = Color(0xFF625B71);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);

  // Text colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
        .copyWith(secondary: accentColor, error: errorColor),
  );
}