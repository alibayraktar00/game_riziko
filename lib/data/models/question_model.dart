import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.category,
    required super.difficulty,
    required super.questionText,
    required super.answers,
    required super.keywords,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json, String id) {
    return QuestionModel(
      id: id,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      questionText: json['question'] as String,
      answers: List<String>.from(json['answers'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'difficulty': difficulty,
      'question': questionText,
      'answers': answers,
      'keywords': keywords,
    };
  }
}
