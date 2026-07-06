import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'glass_card.dart';

/// Rank badge + name + score row for scoreboard/leaderboard lists, with a
/// gold/silver/bronze highlight for the top 3 — previously hand-rolled with
/// slightly different alpha/border values in each ranked-list screen.
class RankedListTile extends StatelessWidget {
  final int rank;
  final String name;
  final String score;
  final bool highlight;

  const RankedListTile({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    this.highlight = false,
  });

  static const _medalColors = {
    1: Color(0xFFFFD700),
    2: Color(0xFFC0C0C0),
    3: Color(0xFFCD7F32),
  };

  @override
  Widget build(BuildContext context) {
    final medal = _medalColors[rank];
    final textTheme = Theme.of(context).textTheme;
    final accent = medal ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        selected: highlight || medal != null,
        accentColor: accent,
        radius: AppRadius.input,
        blur: false,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: medal != null
                  ? Icon(Icons.emoji_events_rounded, color: medal, size: 24)
                  : Text('$rank', style: textTheme.titleMedium, textAlign: TextAlign.center),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(name, style: textTheme.titleMedium, overflow: TextOverflow.ellipsis),
            ),
            Text(score, style: textTheme.titleLarge?.copyWith(color: accent)),
          ],
        ),
      ),
    );
  }
}
