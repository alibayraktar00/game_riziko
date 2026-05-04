import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../widgets/language_picker_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.quiz_rounded,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scaleXY(begin: 1.0, end: 1.05, duration: 2.seconds, curve: Curves.easeInOut),
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
                              blurRadius: 20,
                            ),
                          ],
                        ),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
                  const SizedBox(height: 12),
                  Text(
                    t.translate('app_subtitle'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white54,
                          letterSpacing: 4,
                        ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.5, end: 0),
                  const SizedBox(height: 64),
                  ElevatedButton(
                    onPressed: () => context.push('/team-setup'),
                    child: Text(t.translate('start_game')),
                  ).animate().fadeIn(delay: 800.ms).scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.push('/leaderboard'),
                        icon: const Icon(Icons.leaderboard_rounded),
                        label: const Text('LEADERBOARD'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber,
                          side: const BorderSide(color: Colors.amber),
                        ),
                      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5, end: 0),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/history'),
                        icon: const Icon(Icons.history_rounded),
                        label: const Text('HISTORY'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                      ).animate().fadeIn(delay: 1100.ms).slideY(begin: 0.5, end: 0),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => context.push('/custom-question'),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('ADD CUSTOM QUESTIONS'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ).animate().fadeIn(delay: 1200.ms),
                ],
              ),
            ),

            // Top actions (Settings & Language)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => context.push('/settings'),
                  ).animate().fadeIn(delay: 800.ms),
                  const SizedBox(width: 8),
                  const LanguagePickerButton()
                      .animate()
                      .fadeIn(delay: 1.seconds),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
