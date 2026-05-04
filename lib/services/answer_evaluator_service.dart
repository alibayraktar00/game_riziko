import '../core/utils/levenshtein_utils.dart';
import '../domain/entities/question.dart';

enum AnswerResult {
  correct,
  almostCorrect,
  incorrect,
}

class AnswerEvaluatorService {
  final double similarityThreshold;
  final double almostCorrectThreshold;

  AnswerEvaluatorService({
    this.similarityThreshold = 0.85,
    this.almostCorrectThreshold = 0.65,
  });

  /// Normalizes the input string by trimming, lowering case, and removing punctuation.
  String normalizeText(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single space
  }

  /// Evaluates the user's answer against the given question.
  AnswerResult evaluate(String userAnswer, Question question) {
    final normalizedInput = normalizeText(userAnswer);

    // 1. Keyword-based validation
    // En az bir keyword kullanıcının cevabında bulunmalıdır (OR mantığı).
    if (question.keywords.isNotEmpty) {
      final hasAnyKeyword = question.keywords.any(
        (keyword) => normalizedInput.contains(normalizeText(keyword)),
      );
      if (!hasAnyKeyword) {
        return AnswerResult.incorrect;
      }
    }

    // 2. Exact match or Multiple correct answers checking
    double highestSimilarity = 0.0;

    for (final possibleAnswer in question.answers) {
      final normalizedAnswer = normalizeText(possibleAnswer);
      
      // Exact match
      if (normalizedInput == normalizedAnswer) {
        return AnswerResult.correct;
      }

      // 3. Fuzzy matching using Levenshtein distance
      final similarity = LevenshteinUtils.calculateSimilarity(normalizedInput, normalizedAnswer);
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
      }
    }

    if (highestSimilarity >= similarityThreshold) {
      return AnswerResult.correct;
    } else if (highestSimilarity >= almostCorrectThreshold) {
      return AnswerResult.almostCorrect;
    } else {
      return AnswerResult.incorrect;
    }
  }
}
