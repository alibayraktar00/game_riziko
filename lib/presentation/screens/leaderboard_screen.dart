import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../services/history_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyService = ref.watch(historyServiceProvider);
    final leaderboard = historyService.getLeaderboard();

    return Scaffold(
      appBar: AppBar(
        title: const Text('LEADERBOARD', style: TextStyle(letterSpacing: 2)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: leaderboard.isEmpty
          ? Center(
              child: Text(
                'No scores recorded yet.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                return _buildLeaderboardItem(context, entry, index);
              },
            ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry, int index) {
    final isTop3 = index < 3;
    Color? itemColor;
    if (index == 0) {
      itemColor = Colors.amber;
    } else if (index == 1) {
      itemColor = Colors.grey[400];
    } else if (index == 2) {
      itemColor = Colors.brown[300];
    } else {
      itemColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTop3 ? itemColor!.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
          width: isTop3 ? 2 : 1,
        ),
        boxShadow: isTop3
            ? [
                BoxShadow(
                  color: itemColor!.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isTop3 ? itemColor!.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          foregroundColor: isTop3 ? itemColor : Theme.of(context).colorScheme.primary,
          child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(
          entry.teamName.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isTop3 ? itemColor : Colors.white,
            letterSpacing: 1,
          ),
        ),
        trailing: Text(
          '${entry.score} PTS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: isTop3 ? itemColor : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
