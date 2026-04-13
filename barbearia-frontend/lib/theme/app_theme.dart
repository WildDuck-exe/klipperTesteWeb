import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta Premium - Ponto do Corte
  static const Color primaryNavy = Color(0xFF0F172A); // Deep Navy
  static const Color primaryRed = Color(0xFFDC2626);  // Vibrant Crimson
  static const Color accentBlue = Color(0xFF3B82F6);  // Electric Blue
  
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF0F172A);
  
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color scaffoldBg = isDark ? bgDark : bgLight;
    final Color cardBg = isDark ? cardDark : cardLight;
    final Color primaryColor = isDark ? accentBlue : primaryNavy;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryNavy,
        brightness: brightness,
        primary: primaryColor,
        secondary: primaryRed,
        surface: cardBg,
        background: scaffoldBg,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      
      // Tipografia Premium
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: isDark ? Colors.white : primaryNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : primaryNavy,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardBg,
        elevation: isDark ? 0 : 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark 
            ? BorderSide(color: Colors.white.withOpacity(0.1), width: 1)
            : BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: isDark ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: isDark ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      ),
    );
  }
}

