import 'package:flutter/material.dart';

/// Maps a category name (English or Turkish keyword) to a representative
/// Material icon. Shared between category_selection_screen and
/// category_picker_screen so both pickers show the same icon per category.
IconData categoryIcon(String category) {
  final lower = category.toLowerCase();
  if (lower.contains('science') || lower.contains('bilim')) {
    return Icons.science_rounded;
  } else if (lower.contains('history') || lower.contains('tarih')) {
    return Icons.castle_rounded;
  } else if (lower.contains('geography') || lower.contains('coğrafya')) {
    return Icons.public_rounded;
  } else if (lower.contains('sports') || lower.contains('spor')) {
    return Icons.sports_basketball_rounded;
  } else if (lower.contains('entertainment') || lower.contains('eğlence')) {
    return Icons.movie_filter_rounded;
  } else if (lower.contains('art') || lower.contains('sanat')) {
    return Icons.palette_rounded;
  } else if (lower.contains('technology') || lower.contains('teknoloji')) {
    return Icons.biotech_rounded;
  } else if (lower.contains('general culture') || lower.contains('genel kültür')) {
    return Icons.menu_book_rounded;
  }
  return Icons.category_rounded;
}

/// Maps a category name to a distinct accent color, so category pickers can
/// give each card its own identity instead of one repeated theme color.
Color categoryColor(String category) {
  final lower = category.toLowerCase();
  if (lower.contains('science') || lower.contains('bilim')) {
    return const Color(0xFF00E5FF);
  } else if (lower.contains('history') || lower.contains('tarih')) {
    return const Color(0xFFFFB300);
  } else if (lower.contains('geography') || lower.contains('coğrafya')) {
    return const Color(0xFF00E676);
  } else if (lower.contains('sports') || lower.contains('spor')) {
    return const Color(0xFFFF6D00);
  } else if (lower.contains('entertainment') || lower.contains('eğlence')) {
    return const Color(0xFFFF4081);
  } else if (lower.contains('art') || lower.contains('sanat')) {
    return const Color(0xFFB388FF);
  } else if (lower.contains('technology') || lower.contains('teknoloji')) {
    return const Color(0xFF2979FF);
  } else if (lower.contains('general culture') || lower.contains('genel kültür')) {
    return const Color(0xFF1DE9B6);
  }
  return const Color(0xFF00E5FF);
}
