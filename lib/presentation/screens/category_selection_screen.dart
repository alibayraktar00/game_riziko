import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';
import '../providers/providers.dart';

class CategorySelectionScreen extends ConsumerWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    final gameState = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CATEGORIES'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => context.push('/scoreboard'),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.1, duration: 1.seconds),
          const SizedBox(width: 8),
        ],
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (gameState.availableQuestions.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(gameProvider.notifier).setQuestions(questions);
            });
            return const Center(child: CircularProgressIndicator());
          }

          final categories = gameState.availableQuestions
              .map((q) => q.category)
              .toSet()
              .toList();

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'GAME OVER!',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ).animate().fadeIn().scaleXY(),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.push('/scoreboard'),
                    child: const Text('VIEW FINAL SCORES'),
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            );
          }

          final currentTeam = gameState.currentTeam;

          return Column(
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
                    const Text(
                      'CURRENT TURN',
                      style: TextStyle(color: Colors.white54, letterSpacing: 2, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTeam.name.toUpperCase(),
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
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          context.push('/difficulty-selection', extra: category);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              category.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
