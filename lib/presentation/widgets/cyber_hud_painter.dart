import 'package:flutter/material.dart';

/// Glowing corner-bracket + dot-grid overlay used on selectable HUD-style
/// cards (game mode cards, team format cards). Shared so the effect stays
/// pixel-identical everywhere instead of drifting between copies.
class CyberHudPainter extends CustomPainter {
  final Color color;
  final bool isSelected;
  final double cornerLength;

  const CyberHudPainter({
    required this.color,
    required this.isSelected,
    this.cornerLength = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: isSelected ? 0.55 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const double inset = 6.0;
    final double len = cornerLength;

    canvas.drawLine(const Offset(inset, inset), Offset(inset + len, inset), paint);
    canvas.drawLine(const Offset(inset, inset), Offset(inset, inset + len), paint);

    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset - len, inset), paint);
    canvas.drawLine(Offset(size.width - inset, inset), Offset(size.width - inset, inset + len), paint);

    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset + len, size.height - inset), paint);
    canvas.drawLine(Offset(inset, size.height - inset), Offset(inset, size.height - inset - len), paint);

    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset - len, size.height - inset), paint);
    canvas.drawLine(Offset(size.width - inset, size.height - inset), Offset(size.width - inset, size.height - inset - len), paint);

    final dotPaint = Paint()
      ..color = color.withValues(alpha: isSelected ? 0.06 : 0.015)
      ..style = PaintingStyle.fill;

    final double spacing = size.width / 6;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CyberHudPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isSelected != isSelected;
  }
}
