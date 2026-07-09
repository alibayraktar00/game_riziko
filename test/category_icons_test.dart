import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riziko/core/category_icons.dart';
import 'package:riziko/services/ai_question_service.dart';

void main() {
  group('categoryIcon / categoryColor', () {
    test('every known AI category gets a dedicated icon', () {
      for (final category in AiQuestionService.categories) {
        expect(categoryIcon(category), isNot(Icons.category_rounded),
            reason: '$category should have a dedicated icon');
      }
    });

    test('the 8 known categories map to 8 distinct colors', () {
      final colors = AiQuestionService.categories.map(categoryColor).toSet();
      expect(colors.length, AiQuestionService.categories.length,
          reason: 'tiles must stay visually distinguishable in the picker');
    });

    test('matching is case-insensitive, mirroring how pickers normalize category strings', () {
      expect(categoryIcon('science'), categoryIcon('Science'));
      expect(categoryColor('science'), categoryColor('Science'));
    });

    test('unknown category falls back to a generic icon', () {
      expect(categoryIcon('Made Up Category'), Icons.category_rounded);
    });
  });
}
