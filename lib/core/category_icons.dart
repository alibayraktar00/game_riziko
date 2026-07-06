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
