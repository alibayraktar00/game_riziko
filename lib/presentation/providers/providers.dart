import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/repositories/question_repository.dart';
import '../../services/answer_evaluator_service.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepositoryImpl();
});

final answerEvaluatorServiceProvider = Provider<AnswerEvaluatorService>((ref) {
  return AnswerEvaluatorService();
});

final questionsProvider = FutureProvider((ref) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getQuestions();
});
