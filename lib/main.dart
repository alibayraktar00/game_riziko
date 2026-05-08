import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_options.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final sharedPreferences = await SharedPreferences.getInstance();
  
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
    child: const RizikoApp(),
  ));
}

class RizikoApp extends ConsumerWidget {
  const RizikoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    // Cyber/Neon Dark Palette
    const Color backgroundDark = Color(0xFF0B0F19);
    const Color surfaceDark = Color(0xFF151E2E);
    const Color primaryCyan = Color(0xFF00E5FF);
    const Color accentPurple = Color(0xFFD500F9);

    final textTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return MaterialApp.router(
      title: 'Riziko Quiz Game',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: primaryCyan,
          secondary: accentPurple,
          surface: surfaceDark,
          surfaceContainer: surfaceDark,
        ),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: backgroundDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 8,
          shadowColor: primaryCyan.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryCyan,
            foregroundColor: backgroundDark,
            elevation: 4,
            shadowColor: primaryCyan.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryCyan, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
