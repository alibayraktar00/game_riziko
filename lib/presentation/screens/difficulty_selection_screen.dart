import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../providers/game_provider.dart';

class DifficultySelectionScreen extends ConsumerWidget {
  final String category;

  const DifficultySelectionScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);
    final availableQuestions = gameState.availableQuestions.where((q) => q.category == category).toList();
    
    final availableDifficulties = availableQuestions.map((q) => q.difficulty).toSet().toList();
    availableDifficulties.sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('${t.translate(category.toLowerCase()).toUpperCase()} - ${t.translate('difficulty')}'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
            ),
            child: Column(
              children: [
                Text(
                  t.translate('current_turn'),
                  style: const TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  gameState.currentTeam.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn().shimmer(duration: 2.seconds),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 5,
              itemBuilder: (context, index) {
                final difficultyLevel = index + 1;
                final isAvailable = availableDifficulties.contains(difficultyLevel);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: isAvailable
                        ? () {
                            context.push('/question', extra: {
                              'category': category,
                              'difficulty': difficultyLevel,
                            });
                          }
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isAvailable
                            ? _getDifficultyColor(difficultyLevel).withValues(alpha: 0.15)
                            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                        border: Border.all(
                          color: isAvailable
                              ? _getDifficultyColor(difficultyLevel).withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.05),
                          width: 2,
                        ),
                        boxShadow: isAvailable
                            ? [
                                BoxShadow(
                                  color: _getDifficultyColor(difficultyLevel).withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: ListTile(
                        enabled: isAvailable,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        title: Text(
                          '${t.translate('level')} $difficultyLevel',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isAvailable ? Colors.white : Colors.white38,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? _getDifficultyColor(difficultyLevel).withValues(alpha: 0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${difficultyLevel * 10} PTS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? _getDifficultyColor(difficultyLevel) : Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: -0.2, end: 0, curve: Curves.easeOutBack),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1: return const Color(0xFF00E676); // Accent Green
      case 2: return const Color(0xFF00B0FF); // Light Blue
      case 3: return const Color(0xFFFFEA00); // Yellow
      case 4: return const Color(0xFFFF9100); // Orange
      case 5: return const Color(0xFFFF1744); // Red
      default: return Colors.grey;
    }
  }
}
