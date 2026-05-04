import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/match_result.dart';
import '../../services/history_service.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyService = ref.watch(historyServiceProvider);
    final history = historyService.getMatchHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MATCH HISTORY', style: TextStyle(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                'No match history found.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final match = history[index];
                return _buildMatchCard(context, match);
              },
            ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchResult match) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(match.date),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'WINNER: ${match.winnerTeamName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1,
              ),
            ),
            const Divider(height: 24),
            ...match.teams.map((team) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(team.name),
                      Text(
                        '${team.score} PTS',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
