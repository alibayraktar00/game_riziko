import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String category;
  final int difficulty; // 1 to 5
  final String questionText;
  final List<String> answers;
  final List<String> keywords;

  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.questionText,
    required this.answers,
    required this.keywords,
  });

  @override
  List<Object?> get props => [id, category, difficulty, questionText, answers, keywords];
}
