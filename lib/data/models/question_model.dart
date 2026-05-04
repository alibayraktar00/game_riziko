import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.category,
    required super.difficulty,
    required super.translations,
    required super.answers,
    required super.keywords,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json, String id) {
    // Yeni format: translations: {'en': '...', 'tr': '...'}
    // Eski format için geriye dönük uyumluluk: question: '...' alanı varsa
    Map<String, String> translations;
    if (json['translations'] != null) {
      translations = Map<String, String>.from(json['translations'] as Map);
    } else {
      // Eski format – sadece İngilizce metin var, TR'ye de kopyala
      final text = json['question'] as String? ?? '';
      translations = {'en': text, 'tr': text};
    }

    return QuestionModel(
      id: id,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      translations: translations,
      answers: List<String>.from(json['answers'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'difficulty': difficulty,
      'translations': translations,
      'answers': answers,
      'keywords': keywords,
    };
  }
}
