import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riziko/domain/entities/question.dart';
import 'package:riziko/presentation/providers/game_provider.dart';

Question _q(String category, int difficulty, {String id = ''}) {
  return Question(
    id: id.isEmpty ? '${category}_$difficulty' : id,
    category: category,
    difficulty: difficulty,
    translations: const {'en': 'q', 'tr': 's'},
    answers: const ['a'],
    keywords: const ['a'],
  );
}

void main() {
  group('GameNotifier category normalization', () {
    test('startGame treats differently-cased/spaced categories as the same slot', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final questions = [
        _q('Science', 1, id: 'static-science'),
        _q(' science ', 1, id: 'ai-science-dup'), // same slot, different casing/whitespace
        _q('History', 1, id: 'static-history'),
      ];

      container.read(gameProvider.notifier).startGame(questions);

      final available = container.read(gameProvider).availableQuestions;
      expect(available.length, 2, reason: 'the two "science" variants collapse into one slot');
      expect(available.map((q) => q.id), contains('static-science'));
      expect(available.map((q) => q.id), contains('static-history'));
    });

    test('startGameWithCategories matches selected categories case-insensitively', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final questions = [
        _q('Geography', 1, id: 'geo-1'),
        _q('Geography', 2, id: 'geo-2'),
        _q('Sports', 1, id: 'sports-1'),
      ];

      // User picked the lowercase display form; data is stored capitalized.
      container.read(gameProvider.notifier).startGameWithCategories(questions, ['geography']);

      final state = container.read(gameProvider);
      expect(state.availableQuestions.map((q) => q.id).toSet(), {'geo-1', 'geo-2'});
      expect(state.selectedCategories, ['geography']);
    });

    test('startGameWithCategories excludes categories not selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final questions = [_q('Art', 1, id: 'art-1'), _q('Sports', 1, id: 'sports-1')];

      container.read(gameProvider.notifier).startGameWithCategories(questions, ['Art']);

      final available = container.read(gameProvider).availableQuestions;
      expect(available.map((q) => q.id), ['art-1']);
    });
  });
}
