import 'package:edit_distance/edit_distance.dart';

class LevenshteinUtils {
  static final _levenshtein = Levenshtein();

  /// Calculates the similarity between two strings as a value between 0.0 and 1.0.
  /// 1.0 means exactly the same, 0.0 means completely different.
  static double calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final distance = _levenshtein.distance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    return 1.0 - (distance / maxLength);
  }
}
