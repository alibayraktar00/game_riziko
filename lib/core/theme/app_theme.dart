import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RizikoTheme { neon, royal, cyber }

class AppTheme {
  static ThemeData getTheme(RizikoTheme theme) {
    switch (theme) {
      case RizikoTheme.royal:
        return _buildTheme(
          primary: const Color(0xFFFFD700), // Gold
          secondary: const Color(0xFFC0C0C0), // Silver
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF0D0D0D),
        );
      case RizikoTheme.cyber:
        return _buildTheme(
          primary: const Color(0xFFFF007F), // Pink
          secondary: const Color(0xFF00FF88), // Cyan/Green
          surface: const Color(0xFF1A0B2E),
          background: const Color(0xFF0F051D),
        );
      case RizikoTheme.neon:
      default:
        return _buildTheme(
          primary: const Color(0xFF00E5FF), // Electric Blue
          secondary: const Color(0xFFD500F9), // Purple
          surface: const Color(0xFF131B2F),
          background: const Color(0xFF0B0F19),
        );
    }
  }

  static ThemeData _buildTheme({
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: background,
        onSecondary: Colors.white,
        onSurface: const Color(0xFFE2E8F0),
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
        headlineLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
        bodyLarge: GoogleFonts.outfit(color: const Color(0xFFF8FAFC), fontSize: 16),
      ),
    );
  }

  // Backward compatibility for existing screens
  static ThemeData get darkTheme => getTheme(RizikoTheme.neon);

  static BoxDecoration get neonGradient => const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  static BoxShadow get neonShadow => BoxShadow(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
        blurRadius: 20,
        spreadRadius: 0,
      );

  static TextStyle get titleStyle => GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [
          const Shadow(color: Color(0xFF00E5FF), blurRadius: 20),
          const Shadow(color: Color(0xFFD500F9), blurRadius: 30),
        ],
      );

  static TextStyle get buttonStyle => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0B0F19),
      );

  static BoxDecoration get cardGradient => BoxDecoration(
        color: const Color(0xFF131B2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      );
}
