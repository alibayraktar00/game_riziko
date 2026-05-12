import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFD700), // Neon sarı
        secondary: Color(0xFFFF6B35), // Neon turuncu
        tertiary: Color(0xFF00FF88), // Neon yeşil
        surface: Color(0xFF0F172A), // Koyu arka plan
        error: Color(0xFFFF4444), // Neon kırmızı
        onPrimary: Color(0xFF1A1A2E), // Koyu metin
        onSecondary: Color(0xFF1A1A2E), // Koyu metin
        onSurface: Color(0xFFF1F5F9), // Açık metin
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A1A2E),
        surfaceTintColor: const Color(0xFFFFD700),
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFD700),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFD700),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.8),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color:Color(0xFFFFD700),
            width: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:  Color(0xFF1A1A2E).withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:  BorderSide(color:  Color(0xFFFF6B35), width: 3),
        ),
        labelStyle: GoogleFonts.orbitron(
          color:  Color(0xFFFFD700),
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.orbitron(
          color:  Color(0xFF94A3B8),
          fontSize: 14,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.orbitron(
          color: const Color(0xFFF1F5F9),
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.orbitron(
          color: const Color(0xFFF1F5F9),
          fontSize: 14,
        ),
        headlineLarge: GoogleFonts.orbitron(
          color: const Color(0xFFFFD700),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.orbitron(
          color: const Color(0xFFFFD700),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: const Color(0xFFF1F5F9),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static BoxDecoration get neonGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFFFD700), // Neon sarı
          Color(0xFFFF6B35), // Neon turuncu
          Color(0xFFFF4444), // Neon kırmızı
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static BoxDecoration get cardGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF1A1A2E).withValues(alpha: 0.9),
          const Color(0xFF252542).withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
          blurRadius: 40,
          spreadRadius: -10,
          offset: const Offset(0, -10),
        ),
      ],
    );
  }

  static BoxShadow get neonShadow {
    return BoxShadow(
      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
      blurRadius: 20,
      spreadRadius: 0,
    );
  }

  static TextStyle get titleStyle {
    return GoogleFonts.orbitron(
      fontSize: 48,
      fontWeight: FontWeight.w900,
      color: const Color(0xFFFFD700),
      shadows: [
        const Shadow(
          color:  Color(0xFFFFD700),
          blurRadius: 20,
          offset: Offset(0, 2),
        ),
        const Shadow(
          color:  Color(0xFFFF6B35),
          blurRadius: 30,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle get buttonStyle {
    return GoogleFonts.orbitron(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF1A1A2E),
    );
  }

  static TextStyle get subtitleStyle {
    return GoogleFonts.orbitron(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFF1F5F9),
    );
  }
}
