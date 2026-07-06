import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../domain/entities/question.dart';

/// Google Gemini API anahtarı — build/run sırasında geçilir:
///   flutter run --dart-define=GEMINI_API_KEY=xxxxx
/// Ücretsiz bir anahtar https://aistudio.google.com/apikey adresinden alınabilir.
const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

/// Belirli bir kategori + zorluk seviyesi ("slot") için Gemini ile yeni
/// trivia soruları üretir. API anahtarı yoksa veya istek başarısız olursa
/// boş liste döner — çağıran taraf (QuestionPoolRepository) statik soru
/// bankasına düşer, uygulama hiçbir zaman kesintiye uğramaz.
class AiQuestionService {
  static const List<String> categories = [
    'Science',
    'History',
    'Geography',
    'Sports',
    'Entertainment',
    'Art',
    'Technology',
    'General Culture',
  ];

  static const List<int> difficulties = [1, 2, 3, 4, 5];

  Future<List<Question>> generateForSlot({
    required String category,
    required int difficulty,
    int count = 5,
  }) async {
    if (_geminiApiKey.isEmpty) return [];

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _responseSchema(),
      ),
    );

    try {
      final response = await model
          .generateContent([Content.text(_buildPrompt(category, difficulty, count))])
          .timeout(const Duration(seconds: 25));

      final text = response.text;
      if (text == null || text.isEmpty) return [];

      final decoded = json.decode(text) as Map<String, dynamic>;
      final rawQuestions = decoded['questions'] as List<dynamic>? ?? [];

      var index = 0;
      return rawQuestions
          .map((raw) => _toQuestion(raw as Map<String, dynamic>, category, difficulty, index++))
          .whereType<Question>()
          .toList();
    } catch (_) {
      // Ağ hatası, geçersiz anahtar, kota aşımı, bozuk JSON vb. — sessizce
      // boş liste dön.
      return [];
    }
  }

  Question? _toQuestion(Map<String, dynamic> map, String category, int difficulty, int index) {
    try {
      return Question(
        id: 'ai_${category}_${difficulty}_${DateTime.now().microsecondsSinceEpoch}_$index',
        category: category,
        difficulty: difficulty,
        translations: Map<String, String>.from(
          (map['translations'] as Map).map(
            (key, value) => MapEntry(key as String, value as String),
          ),
        ),
        answers: List<String>.from(map['answers'] as List),
        keywords: List<String>.from(map['keywords'] as List),
        distractors: Map<String, List<String>>.from(
          (map['distractors'] as Map).map(
            (key, value) => MapEntry(key as String, List<String>.from(value as List)),
          ),
        ),
        isCustom: true,
      );
    } catch (_) {
      return null;
    }
  }

  Schema _responseSchema() {
    return Schema.object(properties: {
      'questions': Schema.array(
        items: Schema.object(properties: {
          'translations': Schema.object(properties: {
            'en': Schema.string(),
            'tr': Schema.string(),
          }),
          'answers': Schema.array(items: Schema.string()),
          'keywords': Schema.array(items: Schema.string()),
          'distractors': Schema.object(properties: {
            'en': Schema.array(items: Schema.string()),
            'tr': Schema.array(items: Schema.string()),
          }),
        }),
      ),
    });
  }

  String _buildPrompt(String category, int difficulty, int count) {
    return '''
Bir bilgi yarışması (trivia quiz) uygulaması için yeni sorular üret.

Kategori: $category
Zorluk seviyesi: $difficulty (1: çok temel/genel kültür, 5: uzman seviyesi/detaylı bilgi gerektiren)

$count adet soru üret. Her soru nesnesi şu alanları içermeli:
- "translations": {"en": "İngilizce soru metni", "tr": "Türkçe soru metni"}
- "answers": kabul edilebilir doğru cevapların listesi, küçük harf,
  alternatif yazımlar/eş anlamlılar dahil
- "keywords": cevabı eşleştirmek için kullanılacak kısa anahtar kelimeler
- "distractors": {"en": [3 yanlış şık], "tr": [3 yanlış şık]} — çoktan
  seçmeli modda kullanılacak yanlış ama akla yatkın şıklar

Kurallar:
- Sorular kısa, net olmalı ve tek bir doğru cevabı olmalı.
- Zorluk seviyesine tam uygun olmalı (1 çok kolay, 5 çok zor/uzman düzeyi).
- Klişe/basmakalıp sorulardan kaçın, her seferinde farklı ve özgün sorular üret.
- "distractors" MUTLAKA sorunun konusuyla doğrudan ilgili olmalı ve doğru
  cevapla aynı türde olmalı (örn. doğru cevap bir gezegense çeldiriciler de
  başka gezegenler olmalı, doğru cevap bir sayıysa çeldiriciler de yakın
  büyüklükte sayılar olmalı). Asla konuyla alakasız veya saçma bir çeldirici
  üretme (örn. bir coğrafya sorusuna bir kişi ismi çeldirici olarak verme).
- Şıklar birbirine yakın zorlukta olmalı, hiçbiri bariz yanlış görünmemeli.
- Sadece istenen JSON formatında yanıt ver.
''';
  }
}
