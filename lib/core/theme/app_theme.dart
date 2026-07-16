import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum RizikoTheme { neon, royal, cyber }

/// Spacing scale — pick by role instead of guessing a pixel value.
class AppSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner-radius scale, tied to component role so radii stop drifting
/// screen-to-screen (was 12/16/20/22/24/28/32 used interchangeably).
class AppRadius {
  static const double chip = 12;
  static const double input = 16;
  static const double button = 20;
  static const double card = 24;
  static const double hero = 32;
}

/// Shared glass-surface alpha values so every "frosted card" looks the same.
class AppGlass {
  static const double fill = 0.04;
  static const double fillSelected = 0.12;
  static const double border = 0.1;
  static const double borderSelected = 0.6;
  static const double blur = 16;
}

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
    final baseText = TextTheme(
      displayLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      displayMedium: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
      headlineLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
      headlineMedium: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      titleMedium: GoogleFonts.outfit(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
      titleSmall: GoogleFonts.outfit(color: const Color(0xFFE2E8F0), fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      bodyLarge: GoogleFonts.outfit(color: const Color(0xFFF8FAFC), fontSize: 16, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.outfit(color: const Color(0xFFCBD5E1), fontSize: 14, fontWeight: FontWeight.w500),
      bodySmall: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.outfit(color: background, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
    );

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
        error: const Color(0xFFFF5470),
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          disabledBackgroundColor: primary.withValues(alpha: 0.3),
          disabledForegroundColor: background.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md + 4),
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.35),
          textStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md + 4),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : const Color(0xFF64748B),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08), space: 1),
      textTheme: baseText,
    );
  }

  // Backward compatibility for existing screens
  static ThemeData get darkTheme => getTheme(RizikoTheme.neon);

  static BoxDecoration get neonGradient => BoxDecoration(
        image: DecorationImage(
          image: const ResizeImage(AssetImage('assets/images/background.png'), width: 1080),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF070913).withValues(alpha: 0.8),
            BlendMode.darken,
          ),
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

  /// Standard frosted-glass card surface. Pass [selected] + [accentColor] to
  /// get the highlighted variant used by selectable list/grid items instead
  /// of hand-rolling the alpha values per screen.
  static BoxDecoration cardGradient({
    bool selected = false,
    Color? accentColor,
    double radius = AppRadius.card,
  }) {
    final accent = accentColor ?? const Color(0xFF00E5FF);
    return BoxDecoration(
      color: selected ? accent.withValues(alpha: AppGlass.fillSelected) : Colors.white.withValues(alpha: AppGlass.fill),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: selected ? accent.withValues(alpha: AppGlass.borderSelected) : Colors.white.withValues(alpha: AppGlass.border),
        width: selected ? 1.5 : 1.2,
      ),
    );
  }

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
