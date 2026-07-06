import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/question_pool_repository_impl.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/repositories/question_pool_repository.dart';
import '../../domain/repositories/question_repository.dart';
import '../../services/ai_question_service.dart';
import '../../services/answer_evaluator_service.dart';

import '../../services/custom_content_service.dart';

final aiQuestionServiceProvider = Provider<AiQuestionService>((ref) {
  return AiQuestionService();
});

final questionPoolRepositoryProvider = Provider<QuestionPoolRepository>((ref) {
  final aiQuestionService = ref.watch(aiQuestionServiceProvider);
  return QuestionPoolRepositoryImpl(aiQuestionService);
});

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  final customContentService = ref.watch(customContentServiceProvider);
  final questionPoolRepository = ref.watch(questionPoolRepositoryProvider);
  return QuestionRepositoryImpl(customContentService, questionPoolRepository);
});

final answerEvaluatorServiceProvider = Provider<AnswerEvaluatorService>((ref) {
  return AnswerEvaluatorService();
});

final questionsProvider = FutureProvider((ref) {
  final repository = ref.watch(questionRepositoryProvider);
  return repository.getQuestions();
});
