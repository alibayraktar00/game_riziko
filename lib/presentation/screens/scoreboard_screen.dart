import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_result.dart';
import '../../services/history_service.dart';
import '../providers/game_provider.dart';

class ScoreboardScreen extends ConsumerStatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  ConsumerState<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends ConsumerState<ScoreboardScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _saveMatchData();
    });
  }

  void _saveMatchData() async {
    final gameState = ref.read(gameProvider);
    if (gameState.teams.isEmpty) return;

    final teams = List.of(gameState.teams)..sort((a, b) => b.score.compareTo(a.score));
    final historyService = ref.read(historyServiceProvider);
    
    // Save Match Result
    final matchResult = MatchResult(
      id: gameState.id,
      date: DateTime.now(),
      winnerTeamName: teams.first.name,
      winnerScore: teams.first.score,
      teams: teams.map((t) => TeamResult(name: t.name, score: t.score)).toList(),
    );
    await historyService.saveMatchResult(matchResult);

    // Save Leaderboard Entries
    final leaderboardEntries = teams.map((t) => LeaderboardEntry(
      teamName: t.name,
      score: t.score,
      date: DateTime.now(),
    )).toList();
    await historyService.saveLeaderboardEntries(leaderboardEntries);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final teams = List.of(gameState.teams)..sort((a, b) => b.score.compareTo(a.score));
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate('final_scores'), style: const TextStyle(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/category-selection'),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.1, duration: 1.seconds),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final isWinner = index == 0;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isWinner ? Colors.amber.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isWinner ? Colors.amber : Colors.white.withValues(alpha: 0.05),
                            width: isWinner ? 2 : 1,
                          ),
                          boxShadow: isWinner
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: isWinner ? Colors.amber : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            foregroundColor: isWinner ? Colors.black : Theme.of(context).colorScheme.primary,
                            child: isWinner ? const Icon(Icons.star) : Text('${index + 1}'),
                          ),
                          title: Text(
                            team.name.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 1,
                              color: isWinner ? Colors.amber : Colors.white,
                            ),
                          ),
                          trailing: Text(
                            '${team.score} PTS',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: isWinner ? Colors.amber : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 200).ms).slideX(begin: 0.5, end: 0, curve: Curves.easeOutBack);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(gameProvider.notifier).resetGame();
                          context.go('/');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(t.translate('new_game')),
                      ).animate().fadeIn(delay: 1.seconds),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Text(t.translate('continue_game')),
                      ).animate().fadeIn(delay: 1.2.seconds),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Confetti Animation (Top Center)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // falls downwards
              maxBlastForce: 5, 
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
