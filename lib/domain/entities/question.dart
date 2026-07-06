import 'dart:convert';
import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String category;
  final int difficulty; // 1 to 5
  /// Locale bazlı soru metinleri: {'en': '...', 'tr': '...'}
  final Map<String, String> translations;
  final List<String> answers;
  final List<String> keywords;

  /// Çoktan seçmeli modda kullanılacak, konuyla ilgili mantıklı yanlış
  /// şıklar; translations gibi locale bazlı: {'en': [...], 'tr': [...]}
  /// (AI tarafından soruyla birlikte üretilir). Boşsa question_screen başka
  /// sorulardan çeldirici toplama mantığına düşer.
  final Map<String, List<String>> distractors;

  /// Belirtilen locale için çeldirici listesini döner. Bulunamazsa
  /// İngilizce'ye, o da yoksa boş listeye düşer.
  List<String> getDistractors(String languageCode) {
    return distractors[languageCode] ?? distractors['en'] ?? const [];
  }

  // New media fields
  final String? imageUrl;
  final String? audioUrl;
  final bool isCustom;

  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.translations,
    required this.answers,
    required this.keywords,
    this.distractors = const {},
    this.imageUrl,
    this.audioUrl,
    this.isCustom = false,
  });

  /// Belirtilen locale için soru metnini döner. Bulunamazsa İngilizce'ye düşer.
  String getText(String languageCode) {
    return translations[languageCode] ?? translations['en'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'translations': translations,
      'answers': answers,
      'keywords': keywords,
      'distractors': distractors,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'isCustom': isCustom,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty']?.toInt() ?? 1,
      translations: Map<String, String>.from(map['translations'] ?? {}),
      answers: List<String>.from(map['answers'] ?? []),
      keywords: List<String>.from(map['keywords'] ?? []),
      distractors: (map['distractors'] as Map?)?.map(
            (key, value) => MapEntry(key as String, List<String>.from(value as List)),
          ) ??
          const {},
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      isCustom: map['isCustom'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Question.fromJson(String source) => Question.fromMap(json.decode(source));

  @override
  List<Object?> get props =>
      [id, category, difficulty, translations, answers, keywords, distractors, imageUrl, audioUrl, isCustom];
}
