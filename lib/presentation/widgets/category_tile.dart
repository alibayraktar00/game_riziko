import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'cyber_hud_painter.dart';

/// Full-width row for category pickers: a per-category accent color, a
/// glowing icon badge and a selected state with a check badge — richer than
/// a plain flat list row, while keeping the familiar list layout.
class CategoryTile extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.0 : 0.99,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    accentColor.withValues(alpha: selected ? 0.26 : 0.12),
                    accentColor.withValues(alpha: selected ? 0.06 : 0.02),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withValues(alpha: selected ? 0.8 : 0.18),
                  width: selected ? 1.6 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 18,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: selected ? 0.35 : 0.16),
                      boxShadow: selected
                          ? [BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 14)]
                          : null,
                    ),
                    child: Icon(icon, color: selected ? Colors.white : accentColor, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  AnimatedScale(
                    scale: selected ? 1.0 : 0.6,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: selected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(Icons.check_circle_rounded, color: accentColor, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: CustomPaint(painter: CyberHudPainter(color: accentColor, isSelected: selected)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
