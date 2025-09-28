import 'package:flutter/material.dart';

class AppTheme {
  static const Color kbvGreen = Color(0xFF1E5631);
  static const Color summerbreakBlack = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      fontFamily: 'Bahnschrift',

      appBarTheme: const AppBarTheme(
        backgroundColor: kbvGreen,
        foregroundColor: white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Bahnsahnschrift',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // THE FINAL, CORRECT FIX FOR DISABLED BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(fontFamily: 'Bahnschrift', fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // Using resolveWith allows us to define different styles for different states (enabled, disabled, etc.)
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey.shade400; // Background color when disabled
              }
              return kbvGreen; // Background color for all other states (e.g., enabled)
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.white70; // Text/Icon color when disabled
              }
              return white; // Text/Icon color when enabled
            },
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

