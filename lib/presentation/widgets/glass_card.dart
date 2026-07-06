import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Frosted-glass surface: BackdropFilter blur + AppTheme.cardGradient fill.
/// Replaces the `ClipRRect(child: BackdropFilter(child: Container(decoration:
/// AppTheme.cardGradient)))` boilerplate that was copy-pasted across
/// admin_screen, nickname_screen, waiting_screen, team_setup_screen and
/// question_screen.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool selected;
  final Color? accentColor;
  final bool blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.card,
    this.selected = false,
    this.accentColor,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: AppTheme.cardGradient(selected: selected, accentColor: accentColor, radius: radius),
      child: child,
    );

    if (!blur) return content;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppGlass.blur, sigmaY: AppGlass.blur),
        child: content,
      ),
    );
  }
}
