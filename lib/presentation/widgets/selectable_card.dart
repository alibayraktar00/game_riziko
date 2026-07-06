import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'cyber_hud_painter.dart';
import 'glass_card.dart';

/// Tappable glass card with a selected/unselected visual state — the
/// "selectable list/grid picker" archetype reimplemented independently in
/// category_picker_screen, difficulty_selection_screen and
/// team_setup_screen. One widget, one look.
class SelectableCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentColor;
  final bool showHud;

  const SelectableCard({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.accentColor,
    this.showHud = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: Stack(
        children: [
          GlassCard(
            selected: selected,
            accentColor: accent,
            radius: AppRadius.button,
            blur: false,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: selected ? accent : Colors.white.withValues(alpha: 0.7), size: 26),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(color: selected ? accent : Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle_rounded, color: accent, size: 22),
              ],
            ),
          ),
          if (showHud)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: CyberHudPainter(color: accent, isSelected: selected)),
              ),
            ),
        ],
      ),
    );
  }
}
