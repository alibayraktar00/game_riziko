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
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            Color(0xFF0F1322), // Deep dark blue-black
            Color(0xFF070912), // Near pitch-black
          ],
          stops: [0.0, 1.0],
        ),
      );

  static BoxShadow get neonShadow => BoxShadow(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
        blurRadius: 20,
        spreadRadius: 0,
      );

  static TextStyle get titleStyle => GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        shadows: [
          const Shadow(color: Color(0xFF00E5FF), blurRadius: 15),
          const Shadow(color: Color(0xFFD500F9), blurRadius: 25),
        ],
      );

  static TextStyle get buttonStyle => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0B0F19),
      );

  static BoxDecoration get cardGradient => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.2),
      );

  static BoxDecoration get premiumDarkGradient => const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B0F19), // Deep dark blue-black
            Color(0xFF060913), // Near pitch-black
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  static BoxDecoration darkRadialGradient(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: [
          colorScheme.primary.withValues(alpha: 0.12),
          const Color(0xFF0F1322),
          const Color(0xFF070912),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }
}
