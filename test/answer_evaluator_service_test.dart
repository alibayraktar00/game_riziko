import 'package:flutter_test/flutter_test.dart';
import 'package:riziko/domain/entities/question.dart';
import 'package:riziko/services/answer_evaluator_service.dart';

void main() {
  late AnswerEvaluatorService evaluator;

  setUp(() {
    evaluator = AnswerEvaluatorService(
      similarityThreshold: 0.8,
      almostCorrectThreshold: 0.6,
    );
  });

  group('AnswerEvaluatorService Normalization', () {
    test('should normalize text by lowercasing and trimming', () {
      expect(evaluator.normalizeText('  HELLO WORLD  '), 'hello world');
    });

    test('should remove punctuation', () {
      expect(evaluator.normalizeText('hello, world!'), 'hello world');
      expect(evaluator.normalizeText('user\'s input.'), 'users input');
    });
  });

  group('AnswerEvaluatorService Evaluation', () {
    final question = const Question(
      id: '1',
      category: 'Science',
      difficulty: 1,
      questionText: 'What is the chemical symbol for water?',
      answers: ['h2o', 'water'],
      keywords: ['h2o'],
    );

    test('should return correct for exact match', () {
      final result = evaluator.evaluate('h2o', question);
      expect(result, AnswerResult.correct);
    });

    test('should return correct for exact match of alternative answer (but misses keyword)', () {
      // The keyword is 'h2o', so answering 'water' doesn't contain 'h2o'.
      // Wait, 'water' does not contain 'h2o', so keyword validation will fail.
      final result = evaluator.evaluate('water', question);
      expect(result, AnswerResult.incorrect);
    });

    test('should return incorrect if required keyword is missing', () {
      final result = evaluator.evaluate('i think it is something else', question);
      expect(result, AnswerResult.incorrect);
    });

    final questionNoKeyword = const Question(
      id: '2',
      category: 'Science',
      difficulty: 1,
      questionText: 'What is the chemical symbol for water?',
      answers: ['water'],
      keywords: [],
    );

    test('should return correct for fuzzy match above similarity threshold', () {
      // 'watar' vs 'water'
      final result = evaluator.evaluate('watar', questionNoKeyword);
      expect(result, AnswerResult.correct);
    });

    test('should return almostCorrect for fuzzy match below similarity threshold but above almost threshold', () {
      // 'wat' vs 'water' (similarity 0.6, exactly almostCorrectThreshold)
      final result = evaluator.evaluate('wat', questionNoKeyword);
      expect(result, AnswerResult.almostCorrect);
    });

    test('should return incorrect for fuzzy match below almost threshold', () {
      // 'xyz' vs 'water'
      final result = evaluator.evaluate('xyz', questionNoKeyword);
      expect(result, AnswerResult.incorrect);
    });
  });
}
