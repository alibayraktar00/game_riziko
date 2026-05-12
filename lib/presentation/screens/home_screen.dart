import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../widgets/language_picker_button.dart';
import '../../domain/entities/team.dart';

extension DurationExtensions on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Hero(
                  tag: 'logo',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ).animate()
                  .fadeIn(duration: 800.ms)
                  .scaleXY(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 600.ms),
                ),
                const SizedBox(height: 32),
                Text(
                  'RIZIKO',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                ).animate()
                .fadeIn(delay: 200.ms, duration: 800.ms)
                .slideY(begin: -30, end: 0, duration: 600.ms),
                const SizedBox(height: 12),
                Text(
                  'Çok Oyunculu Quiz Oyunu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white54,
                        letterSpacing: 4,
                      ),
                ).animate()
                .fadeIn(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.5, end: 0, duration: 600.ms),
                const SizedBox(height: 64),
                ElevatedButton(
                  onPressed: () => context.push('/team-setup'),
                  child: const Text('Tek Oyuncu'),
                ).animate()
                .fadeIn(delay: 800.ms, duration: 800.ms)
                .scaleXY(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), duration: 600.ms),
                const SizedBox(height: 16),
                // Multiplayer Options
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ÇOK OYUNCULU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _createMultiplayerGame(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('OYUN OLUŞTUR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ).animate()
                          .fadeIn(delay: 1000.ms, duration: 800.ms)
                          .slideX(begin: -0.2, end: 0, duration: 600.ms),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/multiplayer/scan'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('QR TARA'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ).animate()
                          .fadeIn(delay: 1200.ms, duration: 800.ms)
                          .slideX(begin: 0.2, end: 0, duration: 600.ms),
                        ],
                      ),
                    ],
                  ).animate()
                  .fadeIn(delay: 600.ms, duration: 800.ms)
                  .scaleXY(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 600.ms),
                ),
                const SizedBox(height: 24),
                // Language Picker
                const LanguagePickerButton().animate()
                .fadeIn(delay: 1400.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, duration: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createMultiplayerGame(BuildContext context, WidgetRef ref) async {
    try {
      // TODO: Implement multiplayer service
      
      // TODO: Implement session creation
      final sessionId = 'mock-session-id';
      
      if (context.mounted) {
        context.push('/multiplayer/qr/$sessionId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Oyun oluşturulamadı: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
