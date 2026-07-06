import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/match_result.dart';
import '../../services/history_service.dart';
import '../providers/game_provider.dart';
import '../widgets/ranked_list_tile.dart';
import '../widgets/riziko_scaffold.dart';

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

    return RizikoScaffold(
      title: t.translate('final_scores'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/category-selection'),
      ),
      body: Stack(
          children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CustomPaint(
                        size: Size(160, 160),
                        painter: _SparklePainter(color: Colors.amber),
                      ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
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
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];

                      return RankedListTile(
                        rank: index + 1,
                        name: team.name.toUpperCase(),
                        score: '${team.score} PTS',
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

/// A ring of small diamond sparkles around the trophy — a decorative,
/// code-generated accent so the winner circle doesn't rely on a static glow.
class _SparklePainter extends CustomPainter {
  final Color color;

  const _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    const sparkleCount = 8;
    for (int i = 0; i < sparkleCount; i++) {
      final angle = (2 * pi / sparkleCount) * i;
      final sparkleSize = i.isEven ? 3.5 : 2.0;
      final position = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      _drawSparkle(canvas, position, sparkleSize, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size * 2)
      ..lineTo(center.dx + size * 0.6, center.dy - size * 0.6)
      ..lineTo(center.dx + size * 2, center.dy)
      ..lineTo(center.dx + size * 0.6, center.dy + size * 0.6)
      ..lineTo(center.dx, center.dy + size * 2)
      ..lineTo(center.dx - size * 0.6, center.dy + size * 0.6)
      ..lineTo(center.dx - size * 2, center.dy)
      ..lineTo(center.dx - size * 0.6, center.dy - size * 0.6)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => oldDelegate.color != color;
}
