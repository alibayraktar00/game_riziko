import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../providers/game_provider.dart';
import '../providers/providers.dart';
import '../widgets/language_picker_button.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    final availableQuestions = ref.watch(gameProvider.select((s) => s.availableQuestions));
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('categories')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/team-setup'),
        ),
        actions: [
          const LanguagePickerButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => context.push('/scoreboard'),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 1.seconds),
          const SizedBox(width: 8),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          final categories = availableQuestions
              .map((q) => q.category)
              .toSet()
              .toList();

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.translate('game_over'),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/scoreboard'),
                    child: Text(t.translate('view_final_scores')),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            );
          }

          final currentTeamName = ref.watch(gameProvider.select((s) => s.currentTeam.name));

          return Column(
            children: [
              _CurrentTeamHeader(teamName: currentTeamName, t: t),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final categoryQuestions = availableQuestions.where((q) => q.category == category).toList();
                      
                      return Expanded(
                        child: _CategoryRow(
                          category: category,
                          availableDifficulties: categoryQuestions.map((q) => q.difficulty).toSet().toList(),
                          index: index,
                          t: t,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _CurrentTeamHeader extends StatelessWidget {
  final String teamName;
  final AppLocalizations t;

  const _CurrentTeamHeader({required this.teamName, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            teamName.toUpperCase(),
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
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final List<int> availableDifficulties;
  final int index;
  final AppLocalizations t;

  const _CategoryRow({
    required this.category,
    required this.availableDifficulties,
    required this.index,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIcon = _getCategoryIcon(category);
    final categoryColor = _getCategoryMainColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.2),
            categoryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: categoryColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Stack(
            children: [
              Positioned(
                right: -5,
                bottom: -15,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    categoryIcon,
                    size: 110,
                    color: categoryColor,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translate(category.toLowerCase()).toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: categoryColor.withValues(alpha: 0.5), blurRadius: 12),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              height: 2,
                              width: 30,
                              decoration: BoxDecoration(
                                color: categoryColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            categoryIcon, 
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (idx) {
                        final level = idx + 1;
                        final isAvailable = availableDifficulties.contains(level);
                        
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _DifficultyIndicator(
                              level: level,
                              isAvailable: isAvailable,
                              category: category,
                              color: _getDifficultyColor(level),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.05, end: 0);
  }

  Color _getCategoryMainColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('science') || lowerCategory.contains('bilim')) {
      return const Color(0xFF00E5FF); // Cyan
    } else if (lowerCategory.contains('history') || lowerCategory.contains('tarih')) {
      return const Color(0xFFFFD600); // Amber/Gold
    } else if (lowerCategory.contains('geography') || lowerCategory.contains('coğrafya')) {
      return const Color(0xFF00C853); // Emerald Green
    } else if (lowerCategory.contains('sports') || lowerCategory.contains('spor')) {
      return const Color(0xFFFF6D00); // Deep Orange
    } else if (lowerCategory.contains('entertainment') || lowerCategory.contains('eğlence')) {
      return const Color(0xFFD500F9); // Purple
    } else if (lowerCategory.contains('art') || lowerCategory.contains('sanat')) {
      return const Color(0xFFFF1744); // Red/Pink
    } else if (lowerCategory.contains('technology') || lowerCategory.contains('teknoloji')) {
      return const Color(0xFF2979FF); // Royal Blue
    } else if (lowerCategory.contains('general culture') || lowerCategory.contains('genel kültür')) {
      return const Color(0xFFAA00FF); // Deep Purple
    }
    return const Color(0xFF00E5FF);
  }

  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('science') || lowerCategory.contains('bilim')) {
      return Icons.science_rounded;
    } else if (lowerCategory.contains('history') || lowerCategory.contains('tarih')) {
      return Icons.history_edu_rounded;
    } else if (lowerCategory.contains('geography') || lowerCategory.contains('coğrafya')) {
      return Icons.public_rounded;
    } else if (lowerCategory.contains('sports') || lowerCategory.contains('spor')) {
      return Icons.sports_basketball_rounded;
    } else if (lowerCategory.contains('entertainment') || lowerCategory.contains('eğlence')) {
      return Icons.movie_filter_rounded;
    } else if (lowerCategory.contains('art') || lowerCategory.contains('sanat')) {
      return Icons.palette_rounded;
    } else if (lowerCategory.contains('technology') || lowerCategory.contains('teknoloji')) {
      return Icons.biotech_rounded;
    } else if (lowerCategory.contains('general culture') || lowerCategory.contains('genel kültür')) {
      return Icons.menu_book_rounded;
    }
    return Icons.category_rounded;
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1: return const Color(0xFF00E5FF); // Electric Blue
      case 2: return const Color(0xFF7000FF); // Deep Indigo
      case 3: return const Color(0xFFD500F9); // Vibrant Purple
      case 4: return const Color(0xFFFF007F); // Neon Pink
      case 5: return const Color(0xFFFF3B30); // Crisp Red
      default: return Colors.grey;
    }
  }
}

class _DifficultyIndicator extends StatelessWidget {
  final int level;
  final bool isAvailable;
  final String category;
  final Color color;

  const _DifficultyIndicator({
    required this.level,
    required this.isAvailable,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isAvailable 
        ? () => context.push('/question', extra: {'category': category, 'difficulty': level})
        : null,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: 300.ms,
        height: 56,
        decoration: BoxDecoration(
          gradient: isAvailable ? LinearGradient(
            colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isAvailable ? null : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isAvailable ? color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
          boxShadow: isAvailable ? [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$level',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isAvailable ? Colors.white : Colors.white12,
              ),
            ),
            if (!isAvailable)
              Icon(Icons.lock_outline_rounded, color: Colors.white.withValues(alpha: 0.1), size: 24),
          ],
        ),
      ),
    );
  }
}
